%=========================================================================%
%                            individual states are
%sessionStart
%prepareNextTrial
%run
%timeOut
%trialEnd
%enOfExperiment
%=========================================================================%

% sessionStart-------------(session initiates with experimenter's input
% this can be modified later for animal initiation

function fhandle = sessionStart

global EXP;
global SESSION;
global TRIAL;
global SESSION2REPLAY;
global TRIAL_COUNT;
global rewardStartT;
global rewardStopSmallT;
global rewardStopLargeT;
global oBeepSTART;
global oBeepCORRECT;
global oBeepTIMEOUT;
global oBeepWRONG;
global ScanImageUDP;  % the UDP port
global EyeCameraUDP;  % the UDP port
global TimelineUDP;  % the UDP port
global DIRS;
global OFFLINE;
global initParams;
global EXPREF;
global ROOM;


%% defining the valve timer objects, should be moved to I/O initialization
% open = 0;
% close = 1;
rewardStartT = timer('TimerFcn', 'reward(0.0)');

rewardStopSmallT= timer('TimerFcn', 'reward(1.0)','StartDelay', EXP.smallRewardTime );

rewardStopLargeT= timer('TimerFcn', 'reward(1.0)','StartDelay', EXP.largeRewardTime );

%% defining the sounds for sound signals

sRate = Snd('DefaultRate');

beepSTART  = 0.5*MakeBeep(3300, 0.1, sRate);
beepCORRECT  = 0.5*MakeBeep(6600, 0.1, sRate);
beepTIMEOUT = rand(round(sRate*EXP.timeOutSoundDuration), 1)-0.5;
beepWRONG = rand(round(sRate*0.2), 1)-0.5;

oBeepSTART  = audioplayer(beepSTART, sRate);
oBeepCORRECT  = audioplayer(beepCORRECT, sRate);
oBeepTIMEOUT = audioplayer(beepTIMEOUT, sRate);
oBeepWRONG = audioplayer(beepWRONG, sRate);

%% animal (subject) name

if OFFLINE
    animalName = 'fake';
elseif ~isempty(initParams)
    animalName=initParams.animalName;
else
    animalName = input('Please enter mouse name: ','s');
end

if isempty(animalName)
    animalName = 'fake';
end

%% session name (by default using the currnet time in HHMM format)
if OFFLINE
    sessionName = '9999';
elseif ~isempty(initParams)
    sessionName=initParams.sessionName;
else
    sessionName = input('Please enter session id: ','s');
end

if isempty(sessionName)
    sessionName = datestr(now, 'HHMM');
end

sessionName = str2num(sessionName);

%% current date
dateString = datestr(now, 'yyyy-mm-dd');

%% defining the paths (both server and local)

EXPREF = dat.constructExpRef(animalName, dateString, sessionName);
EXP.expRef = EXPREF;
[folders, filename] = dat.expFilePath(EXPREF, 'tmaze');

DIRS.localFolder = fileparts(folders{1});
DIRS.serverFolder = fileparts(folders{2});
DIRS.fileName = filename;

try
    if ~isdir(DIRS.serverFolder)
        mkdir(DIRS.serverFolder);
    end
catch
    warning('There was a problem creating the folder %s on the server', DIRS.serverFolder);
end

try
    if ~isdir(DIRS.localFolder)
        mkdir(DIRS.localFolder);
    end
catch
    warning(['There was a problem creating a local folder %s', DIRS.localFolder]);
end

%% setting experimental params----------------------------------------------

EXP = setExperimentPars;
if isequal(EXP.stimType, 'REPLAY')
    % this bit of code is potentially not working (with the new file/pathnames
    % used)
    [FileName, PathName]=uigetfile('*_TMaze.mat', '', fullfile(DIRS.localFolder, '..'));
    data=load([PathName filesep FileName]);
    EXP=data.EXP;
    EXP.expRef = EXPREF;
    EXP.stimType='REPLAY';
    %     ind=data.SESSION.allTrials
    nTrials=length(data.SESSION.allTrials);
    ind=true(1, nTrials);
    for iTrial=1:nTrials
        if isequal(EXP.replayMode, 'notTIMEOUT') && ...
                isequal(data.SESSION.allTrials(iTrial).info.outcome, 'TIMEOUT')
            ind(iTrial)=false;
        end
    end
    data.SESSION.allTrials=data.SESSION.allTrials(ind);
    data.SESSION.stimSequence=data.SESSION.stimSequence(ind);
    data.SESSION.contrastSequence=data.SESSION.contrastSequence(ind);
    
    EXP.maxNTrials=length(data.SESSION.allTrials);
    if isequal(data.SESSION.allTrials(end).info.outcome, 'USER ABORT')
        EXP.maxNTrials=EXP.maxNTrials-1;
    end
    SESSION2REPLAY=data.SESSION;
end

if isequal(EXP.stimType, 'REPLAY_SCRAMBLED')
    % this bit of code is potentially not working (with the new file/pathnames
    % used)
    [FileName, PathName]=uigetfile('*_TMaze.mat', '', fullfile(DIRS.localFolder, '..'));
    data=load([PathName filesep FileName]);
    %     ind=data.SESSION.allTrials
    EXP.expRef = EXPREF;
    EXP.maxNTrials=1;
    TRIAL = makeScrambled(data);
end

%% MK - a simple geometry correction
% this one meaning that if the stimulus is on both sides we imply that the
% corridor is strictly linear (might not be true in general), and if it is
% not on both sides, then it must be a T-Maze

if isequal(EXP.stimType, 'BOTH')
    EXP.roomWidth=EXP.corridorWidth;
else
    EXP.roomWidth=3*EXP.corridorWidth;
end

if isequal(EXP.stimType, 'REPLAY_SCRAMBLED')
    ROOM = getRoomData(data.EXP);
else
    ROOM = getRoomData(EXP);
end

%% MK - this part builds a set of textures suitable for the t-maze task
% in addition it builds a sequence of stimuli to be used in the experiment
% options.gratingContrasts=[0 6 12 25 50];
if isequal(EXP.stimType, 'REPLAY')
    SESSION.textures=SESSION2REPLAY.textures;
    SESSION.options=SESSION2REPLAY.options;
elseif isequal(EXP.stimType, 'REPLAY_SCRAMBLED')
    SESSION.textures=data.SESSION.textures;
    SESSION.options = data.SESSION.options;
else
    options.gratingContrasts=EXP.contrasts;
    options.noiseContrast=EXP.noiseContrast;
    options.floorContrast=EXP.floorContrast;
    options.sfMultiplier=EXP.sfMultiplier;
    options.size=EXP.texturePatchSize;
    SESSION.options=options;
    [SESSION.textures tx]=buildTextures(options);
end

buildStimSequence;

% generating an empty structure. Log events will go here
SESSION.Log = struct;

%%
if OFFLINE
    start = 1;
else
    start = input('----when ready to go? PRESS 1 and RETURN!!!');
end

if (start == 1)
    fhandle = @prepareNextTrial;
end
% MK - this looks potentially buggy, what happens if ~(start==1) ????


TRIAL_COUNT = 0;
fprintf('\nStarting MouseBall session %d on %s, animal %s\n', sessionName, dateString, animalName);

%% now send UDPs to all the data hosts
if ~OFFLINE
    [animalID, dateID, sessionID] = dat.expRefToMpep(EXPREF);
    
    msgString = sprintf('ExpStart %s %d %d', animalID, dateID, sessionID);
    
    pnet(ScanImageUDP, 'write', msgString);
    pnet(ScanImageUDP, 'writePacket');
    
    pnet(EyeCameraUDP, 'write', msgString);
    pnet(EyeCameraUDP, 'writePacket');
    
    pnet(TimelineUDP, 'write', msgString);
    pnet(TimelineUDP, 'writePacket');
    
    % wait for everybody to start
    pause(7);
    
end
return;
end

