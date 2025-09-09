
function h=figtitle(txt,varargin)
% plot text title on the top of a figure
% For: plotting
% figtitle(txt)
% figtitle(txt,'name',value)
% h=figtitle(...)   % get text
% INPUT: txt: text string
%        name,value: string and value of plotting properties for 
%                    'annotation' function
% OUTPUT: h: annotation object
% Kefei
% 2021-10-11, create
% 2022-6-20, change the plotting method from 'text' to 'annotation'

if nargin<1
    txt='Figure title';
end

% set(gca,'Nextplot','add');
% newplot(findall(gcf,'Type','Axes'));
% subplot('position',[0.48,0.98,0.1,0.02])
% set(gca,'xlim',[0,1],'ylim',[0,1]);
if ~ischar(txt)
    txt=num2str(txt);
end
% text(0,0,txt,'fontweight','bold',varargin{:});axis off;
ai=inputParser;
ai.addParameter('FontSize',12);
ai.addParameter('FontWeight','bold');
ai.parse(varargin{:});
ai=struct2cellname (ai.Results);

h=annotation('textbox', [0, 1, 1, 0], 'string', txt,'FitBoxToText','on',...
    'LineStyle','none','HorizontalAlignment','center',ai{:});


function b=struct2cellname(a)

b1=fieldnames(a);
b2=struct2cell(a);
b=[b1(:),b2(:)]';
b=b(:)';