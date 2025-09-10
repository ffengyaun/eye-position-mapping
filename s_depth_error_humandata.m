% s_depth_error_humandata.m
% % Mingnan Wei, 2024\11\25 translated by Fengyuan，2025/9/10
% rawdatahuman eye tracter in 6 different depth（40，60，80，100，120，150）
% \rawdata\Env_1data from environment camera
% \rawdata\Eye_2data from right eye camera
% \rawdata\Eye_3data from left eye camera
% 
% data is stored in txt file，three env camaera in every depth had same time stamp
% for example, thses are the three camera in the depth of 40：
% \raw_data\Env_1\Env_1_offline_40.txt
% \raw_data\Eye_2\Eye_2_offline_40.txt
% \raw_data\Eye_2\Eye_3_offline_40.txt
% 
% datastrecture：
% Each line reprents the 2D location with the same time stamp. The env camera is the cntre of the gae position, while the eye cam is the cetre of pupil position.
% forexampale \raw_data\Env_1\Env_1_offline_40.txt, is the first three lines:
% 306 250
% 306 250
% 219 219
% 
% corresponding to the fisrt three line of \raw_data\Eye_2\Eye_2_offline_40.txt,:
% 253 181
% 253 182
% 268 180
% 
% and the first three lines of \raw_data\Eye_3\Eye_3_offline_40.txt,:
% 337 110
% 336 111
% 349 108
% It means that when the subjects gaze at the screen during thre calibration process, in this time, the gaze position from env camera is located at(306,250), 
% the pupile position from right eye camera is located at(253,181), the pupile position from right eye camera is located at(337,110);
% In next time stamp, the gaze position from env camera is located at(306,250), 
% the pupile position from right eye camera is located at(253,182), the pupile position from right eye camera is located at(337,110);
%% save to mat. only need to run once

cd 'C:\Users\zfy\Desktop\s_depth_error_humandata_Sources_041224_164534'

tmp=dir;
tmp=tmp(3:end);
camnames={tmp([tmp.isdir]).name};

for i=1:length(camnames)
    eval(sprintf('%s=struct;',camnames{i}))
    cd(camnames{i});
    tmp=dir('*.txt');
    for j=1:length(tmp)
        data=load(tmp(j).name);
        eval(sprintf('%s.%s=data;',camnames{i},tmp(j).name(7:end-4)))
    end
    cd ..
end

% convert format
% posdata: [samples,var,camera] 2dim: 1 x, 2 y, 3 depth, 4 cam (1env,2 Eye_2,3 Eye_3), 5 time index
posdata_str={'x', 'y', 'depth',  'cam','time index'};

depthstr=fieldnames(Env_1);
depthvalue=cellfun(@(x) str2num(x(strfind(x,'offline')+8 :end)),depthstr);

posdata=[];
tmp=struct2cell(Env_1);
tmplen=cellfun(@length, tmp);
tind=0;
for i=1:length(tmp)
    posdata=[posdata; 
        tmp{i} , repmat(depthvalue(i),tmplen(i),1), repmat(1,tmplen(i),1), (tind+1:tind+tmplen(i))' ];
    tind=tind+tmplen(i);
end

posdata1=[];
tmp=struct2cell(Eye_2);
tmplen=cellfun(@length, tmp);
tind=0;
for i=1:length(tmp)
    posdata1=[posdata1; 
        tmp{i} , repmat(depthvalue(i),tmplen(i),1), repmat(2,tmplen(i),1), (tind+1:tind+tmplen(i))' ];
    tind=tind+tmplen(i);
end
posdata=cat(3,posdata,posdata1);


posdata1=[];
tmp=struct2cell(Eye_3);
tmplen=cellfun(@length, tmp);
tind=0;
for i=1:length(tmp)
    posdata1=[posdata1; 
        tmp{i} , repmat(depthvalue(i),tmplen(i),1), repmat(3,tmplen(i),1), (tind+1:tind+tmplen(i))' ];
    tind=tind+tmplen(i);
end
posdata=cat(3,posdata,posdata1);

 % posdata: [samples,var,camera] 2dim: 1 x, 2 y, 3 depth, 4 cam (1env,2 Eye_2,3 Eye_3), 5 time index
% posdata_str={'x', 'y', 'depth',  'cam','time index'};
save('alldata.mat', camnames{:}, 'posdata','posdata_str')

%% 

load('C:\Users\zfy\Desktop\s_depth_error_humandata_Sources_041224_164534\alldata.mat')

%% plot data
figure;

ax1=subplot(221);
plot3(Env_1.offline_100(:,1),Env_1.offline_100(:,2),1:size(Env_1.offline_100,1),'.'); hold on;
plot3(Env_1.offline_40(:,1),Env_1.offline_40(:,2),1:size(Env_1.offline_40,1),'r.'); 
xlabel('x');ylabel('y');zlabel('Time'); title('Env')

ax3=subplot(224);
plot3(Eye_3.offline_100(:,1),Eye_3.offline_100(:,2),1:size(Eye_3.offline_100,1),'.'); hold on;
plot3(Eye_3.offline_40(:,1),Eye_3.offline_40(:,2),1:size(Eye_3.offline_40,1),'r.')
xlabel('x');ylabel('y');zlabel('Time'); title('Eye3')
ax4=subplot(223);
plot3(Eye_2.offline_100(:,1),Eye_2.offline_100(:,2),1:size(Eye_2.offline_100,1),'.');hold on;
plot3(Eye_2.offline_40(:,1),Eye_2.offline_40(:,2),1:size(Eye_2.offline_40,1),'.');
xlabel('x');ylabel('y');zlabel('Time'); title('Eye2')

linkaxes([ax1,ax3,ax4],'z')
linkprop([ax1,ax3,ax4],{'CameraPosition','CameraUpVector'});

%% stats. distribution of env and eye pos

% for i=1:size(posdata,2)
%     checkdata1(posdata(:,i,2));
%     figtitle(posdata_str{i})
% end

% posdata: [samples,var,camera] 2dim: 1 x, 2 y, 3 depth, 4 cam (1env,2 Eye_2,3 Eye_3), 5 time index
% posdata_str={'x', 'y', 'depth',  'cam','time index'};

% distribution of env and eye pos
nposbin=[10,11];

posstat=struct;
camnum=[1,2,3];
for i=1:3
    
    [posstat(i).posdistribution,posstat(i).posyedge,posstat(i).posxedge,posstat(i).biny,posstat(i).binx] = ...
        histcounts2(posdata(:,2,i),posdata(:,1,i) ,  nposbin);  % y as 1st dim
    posstat(i).yedge1=edge2x(posstat(i).posyedge);
    posstat(i).xedge1=edge2x(posstat(i).posxedge);
    
end

%% plot
    figure('position',[20    69    1368    471]);
camstr={'Env_1','Eye_2','Eye_3'};
    for i=1:3
        subplot(2,3,i);
        z=posstat(i).posdistribution;
        
        imagesc(posstat(i).xedge1,posstat(i).yedge1,z);hb=colorbar;
        hold on;
       [~,hc]= contour(posstat(i).xedge1,posstat(i).yedge1,z,[10,20,30,50:50:200],'r','ShowText','on');
   set(hc,'LabelColor','r')
        title(camstr{i});
    hb.Label.String='number of data points';
    xlabel('X');ylabel('Y');
    set(gca,'ydir','normal')
axis image

       subplot(2,3,3+i);
        histogram(z,50);
    title(camstr{i});
    xlabel('Number of datapoints');ylabel('Position');
    
    end

%% -------------corresponding eye pos and env pos
ieye=2 % eye_2

% binned eye pos: posstat(ieye).binx,  posstat(ieye).biny 
nposbiny=size(posstat(ieye).posdistribution,1);
nposbinx=size(posstat(ieye).posdistribution,2);
envposeye=cell(nposbiny,nposbinx);
envposeyeMean=cell(nposbiny,nposbinx);
for i1=1:nposbiny
    for i2=1:nposbinx
            ind= find(posstat(ieye).biny==i1 & posstat(ieye).binx==i2);
            if isempty(ind);continue;end
            envposeye{i1,i2}=posdata(ind,:,1);
                        % mean%
            [gr,depx]=findgroups(envposeye{i1,i2}(:,3));
            meanxy=splitapply(@(x) mean(x,1), envposeye{i1,i2}(:,[1,2]), gr );
            envposeyeMean{i1,i2}=[meanxy,depx];
    end
end
%% overall error caused by depth
erd=[];
for i1=1:nposbiny
    for i2=1:nposbinx
        tmp=envposeye{i1,i2};
        tmpm=envposeyeMean{i1,i2};
        if size(tmpm,1)<5;continue;end
        maxd=tmpm(end,:);
        tmp(:,[1,2])=tmp(:,[1,2])-maxd([1,2]);   %=====consider the env pos in max depth as ground truth
        erd=[erd; tmp];
    end
end

[gr,depx]=findgroups(erd(:,3));
[erdMean,erdSe]=splitapply(@mean_se,erd(:,[1,2]),gr);

save('depth_error_fromhuman.mat');
%% plot overall error
figure('position',[62.6000  200.2000  816.0000  416.0000])
depthvalue=unique(posdata(:,3,1));
limx=[depthvalue(1)-20, depthvalue(end)+20];

subplot(121)
boxplot(erd(:,1),erd(:,3));
% set(gca,'xlim',limx)
ylabel('X error');  xlabel('Depth(cm)');
subplot(122)
boxplot(erd(:,2),erd(:,3));
ylabel('Y error'); xlabel('Depth(cm)');
% set(gca,'xlim',limx)
%% plot env pos along depth
figure('position',[50    60    1367    988]);
depthvalue=unique(posdata(:,3,1));
limx=[depthvalue(1)-20, depthvalue(end)+20];
for i1=1:nposbiny
    for i2=1:nposbinx
        tmp=envposeye{i1,i2};
        tmpm=envposeyeMean{i1,i2};
        if isempty(tmp);continue;end
        subplot(nposbiny,nposbinx,i2+(i1-1)*nposbinx );
        plot( tmp(:,3), tmp(:,1),'b.' );hold on;
        plot(tmpm(:,3), tmpm(:,1),'b-');
        plot( tmp(:,3), tmp(:,2),'r.' );
        plot(tmpm(:,3), tmpm(:,2),'r-');
        if i1==nposbiny
            xlabel('Depth(cm)');
        end
        if i2==1
            ylabel('pix');
        end
        title(sprintf('eye=[%.0f,%.0f]',posstat(ieye).xedge1(i2), posstat(ieye).yedge1(i1) ))
        set(gca,'box','off','xlim',limx);
    end
end
%% diff with far away depth
figure('position',[50    60    1367    988]);
depthvalue=unique(posdata(:,3,1));
limx=[depthvalue(1)-20, depthvalue(end)+20];
for i1=1:nposbiny
    for i2=1:nposbinx
        tmp=envposeye{i1,i2};
        tmpm=envposeyeMean{i1,i2};
        if isempty(tmp);continue;end
        maxd=tmpm(end,:);
        subplot(nposbiny,nposbinx,i2+(i1-1)*nposbinx );
        plot( tmp(:,3), tmp(:,1)-maxd(1),'b.' );hold on;
        plot(tmpm(:,3), tmpm(:,1)-maxd(1),'b-');
        plot( tmp(:,3), tmp(:,2)-maxd(2),'r.' );
        plot(tmpm(:,3), tmpm(:,2)-maxd(2),'r-');
        if i1==nposbiny
            xlabel('Depth(cm)');
        end
        if i2==1
            ylabel('pix Diff');
        end
        title(sprintf('eye=[%.0f,%.0f]',posstat(ieye).xedge1(i2), posstat(ieye).yedge1(i1) ))
        set(gca,'box','off','xlim',limx);
    end
end


%%  summary
figure('position',[50    60    1367    988]);
depthvalue=unique(posdata(:,3,1));
limx=[depthvalue(1)-20, depthvalue(end)+20];
subplot(121)
for i1=1:nposbiny
    for i2=1:nposbinx
        tmpm=envposeyeMean{i1,i2};
        if size(tmpm,1)<5;continue;end
        maxd=tmpm(end,:);
        plot(tmpm(:,3), tmpm(:,2)-maxd(2),'.-','color',[1-.1*i1, .5, .1*i1],'LineWidth',2 );
        hold on;
    end
end
xlabel('Depth(cm)');ylabel('pix Diff'); title('color: eye Y')
subplot(122)
for i1=1:nposbiny
    for i2=1:nposbinx
        tmpm=envposeyeMean{i1,i2};
        if size(tmpm,1)<5;continue;end
        maxd=tmpm(end,:);
        plot(tmpm(:,3), tmpm(:,1)-maxd(1),'.-','color',[1-.1*i2, .5, .1*i2],'LineWidth',2 );
        hold on;
    end
end
xlabel('Depth(cm)');ylabel('pix Diff'); title('color: eye X')
figtitle('error vs eyepos')

%% % error direction
figure('position',[50    60    1367    988]);
depthvalue=unique(posdata(:,3,1));
limx=[depthvalue(1)-20, depthvalue(end)+20];
for i1=1:nposbiny
    for i2=1:nposbinx
        tmp=envposeye{i1,i2};
        tmpm=envposeyeMean{i1,i2};
        if isempty(tmpm);continue;end
        subplot(nposbiny,nposbinx,i2+(i1-1)*nposbinx );
        
        scatter(tmp(:,1),tmp(:,2),5,tmp(:,3));
        hold on;
        scatter(tmpm(:,1),tmpm(:,2),20,tmpm(:,3),'filled');
        plot(tmpm(:,1),tmpm(:,2),'r')
        
        
        if i1==nposbiny
            xlabel('X');
        end
        if i2==1
            ylabel('Y');
        end
        title(sprintf('eye=[%.0f,%.0f]',posstat(ieye).xedge1(i2), posstat(ieye).yedge1(i1) ))
        set(gca,'box','off');
    end
end
hb=colorbar('position',[ 0.9228    0.1182    0.0029    0.0513],'Ticks',[]);
hb.Label.String='Depth';

% summary
figure('position',[50    60    1367    988]);
depthvalue=unique(posdata(:,3,1));
limx=[depthvalue(1)-20, depthvalue(end)+20];
subplot(121)
for i1=1:nposbiny
    for i2=1:nposbinx
        tmpm=envposeyeMean{i1,i2};
        if size(tmpm,1)<5;continue;end
        maxd=tmpm(end,:);
        plot(tmpm(:,1)-maxd(1), tmpm(:,2)-maxd(2),'.-','color',[1-.1*i1, .5, .1*i1],'LineWidth',2 );
        hold on;
    end
end
xlabel('env x');ylabel('env y'); title('color: eye Y')
subplot(122)
for i1=1:nposbiny
    for i2=1:nposbinx
        tmpm=envposeyeMean{i1,i2};
        if size(tmpm,1)<5;continue;end
        maxd=tmpm(end,:);
        plot(tmpm(:,1)-maxd(1), tmpm(:,2)-maxd(2),'.-','color',[1-.1*i1, .5, .1*i2],'LineWidth',2 );
        hold on;
    end
end
xlabel('env x');ylabel('env y'); title('color: eye X')
figtitle('error direction')

%% 

%% select good pos with enough data
thr=10;
ieye=2
goodpos=posstat(i).posdistribution>thr;

%% 


