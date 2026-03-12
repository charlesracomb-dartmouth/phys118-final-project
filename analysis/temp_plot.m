function temp_plot(direc,opts)
arguments
	direc (1,:) char {mustBeFolder}
	opts.plots (1,:) string = 'all'
	opts.start (1,1) double {mustBeNonempty} = -1
	opts.cad (1,1) double {mustBeNonempty} = -1
	opts.stop (1,1) double {mustBeNonempty} = -1
	opts.alt_ref (1,1) double {mustBePositive} = 300e3
	opts.mlon_ref (1,1) double {mustBeNonempty} = -1
	opts.hsv_sat (1,1) double {mustBeNonempty} = 1e3
	opts.j_range (1,2) double {mustBeNonempty} = [-2e-6,2e-6]
	opts.n_range (1,2) double {mustBeNonempty} = [1e9,1e12]
	opts.p_range (1,2) double {mustBeNonempty} = [-3e3,3e3]
	opts.alt_max (1,1) double {mustBeNonempty} = 400e3
	opts.alt_hsv (1,1) double {mustBeNonempty} = 150e3
	opts.alt_cls (1,1) double {mustBeNonempty} = 120e3
end

colorcet = @aurogem.tools.colorcet;

fts = 8;
ftn = 'Consolas';
clb_fmt = '%+ 6.2f';
clb_exp = 0;
ctr_lc = 'k';
ctr_lw = 0.3;

%%load in grid data
xg = gemini3d.read.grid(direc);
MLAT = 90-squeeze(xg.theta)*180/pi;
MLON = squeeze(xg.phi)*180/pi;
ALT = xg.alt;
x2 = xg.x2(3:end-2);
x3 = xg.x3(3:end-2);
[X2, X3] = ndgrid(x2,x3);
lx2 = xg.lx(2); lx3 = xg.lx(3);
dx1 = xg.dx1h;

%% determine grid reference altitudes/boundaries
lb1 = 1;
[~,ub1] = min(abs(ALT(:,1,1)-alt_max));
lb2 = 3;
ub2 = lx2+1-lb2;
lb3 = 3;
ub3 = lx3+1-lb3;
MLAT = MLAT(lb1:ub1,lb2:ub2,lb3:ub3);
MLON = MLON(lb1:ub1,lb2:ub2,lb3:ub3);
ALT = ALT(lb1:ub1,lb2:ub2,lb3:ub3);
X2 = X2(lb2:ub2,lb3:ub3);
X3 = X3(lb2:ub2,lb3:ub3);
dx1 = dx1(lb1:ub1);

%% load configuration data
cfg = gemini3d.read.config(direc);
ymd = cfg.ymd;
UTsec0 = cfg.UTsec0;
tdur = cfg.tdur;
dtout = cfg.dtout;
dtprec = cfg.dtprec;
dtE0 = cfg.dtE0;
stop = tdur;

UTsec = UTsec0+stop
fprintf([pad(sprintf(' UTsec = %i s ',UTsec),80,'both','-'),'\n'])

%% load simulation data
TOI=cfg.times(end);
params=cfg;
params.msis_infile="tmp/msis_input.h5";
params.msis_outfile="tmp/msis_output.h5";
natm=gemini3d.model.msis(params,xg,TOI);
Tn=natm.Tn
time = datetime(ymd) + seconds(UTsec);
time.format = 'yyyyMMdd' 'T' 'HHmmss.sss';
dat = gemini3d.read.frame(direc,'time',time);
title_tile = char(dat.time);

phi = dat.Phitop;
[E1,E2,E3] = gemscr.postprocess.pot2field(xg,phi);

E0_UTsecs = UTsecs = UTsec0 + (0:dTE0:tdur);
[~,E0_i] = min(abs(E0_UTsecs-UTsec));
E0_time = datetime(ymd) + seconds(E0_UTsecs(E0_i));
E0_fn = fullfile(direc,cfg.E0_dir,[char(gemini3d.datelab(E0_time)),'.h5']);
E2_BG = mean(h5read(E0_fn,'/Exit'),'all');
E3_BG = mean(h5read(E0_fn,'/Eyit'),'all');
E2 = E2 + E2_BG;
E3 = E3 + E3_BG;

E1 = E1(lb1:ub1,lb2:ub2,lb3:ub3);
E2 = E2(lb1:ub1,lb2:ub2,lb3:ub3);
E3 = E3(lb1:ub1,lb2:ub2,lb3:ub3);
Te = dat.Te(lb1:ub1,lb2:ub2,lb3:ub3);
Ti = dat.Ti(lb1:ub1,lb2:ub2,lb3:ub3);

folder = 'temperature';
suffix = 'temp';

figure
set(gcf,'PaperPosition',[0,0,6.5,4.5])
tlo = tiledlayout(2,2)
title(tlo,plot_title,'FontSize',fts,'FontName',ftn,'FontWeight','bold','Interpreter','none')

nexttile
pcolor(squeeze(MLAT(:,mlon_rid,:)),squeeze(ALT_p(:,mlon_rid,:)),squeeze(Te_p(:,mlon_rid,:))
title(['Electron Temp. (',num2str(mlon_rac_p),'°)'])
xlabel(mlat_label)
ylabel(alt_label)
colormap(gca.colorcet(clm.t))
clb = colorbar;
clb.Label.String = ['T_e [',unt.t,']'];
clb.Ruler.Exponent = clb_exp;
clim(Te_range_p)
yline(alt_rac_p,'r--')

nexttile
pcolor(squeeze(MLON(alt_rid,:,:)),squeeze(MLAT(alt_rid,:,:)),squeeze(Te_p(alt_rid,:,:)))
title(['Electron Temp. (',num2str(alt_rac_p),' ',unt.x,')'])
xlabel(mlon_label)
ylabel(mlat_label)
colormap(gca,colorcet(clm.t))
clb = colorbar;
clb.Label.String = ['T_e [',unt.t,']'];
clb.Ruler.Exponent = clb_exp;
clim(Te_range_p)
xline(mlon_rac_p,'r--')

nexttile
pcolor(squeeze(MLAT(:,mlon_rid,:)),squeeze(ALT_p(:,mlon_rid,:)),squeeze(Ti_p(:,mlon_rid,:)))
title(['Ion Temp. (',num2str(mlon_rac_p),'°)'])
xlabel(mlat_label)
ylabel(alt_label)
colormap(gca,colorcet(clm.t))
clb = colorbar;
clb.Label.String = ['T_i [',unt.t,']'];
clb.Ruler.TickLabelFormat = clb_fmt;
clb.Ruler.Exponent = clb_exp;
clim(Ti_range_p)
yline(alt_rac_p,'r--')

nexttile
pcolor(squeeze(MLON(alt_rid,:,:)),squeeze(MLAT(alt_rid,:,:)),squeeze(Ti_p(alt_rid,:,:)))
title(['Ion Temp. (',num2str(alt_rac_p),' ',unt.x,')'])
xlabel(mlon_label)
ylabel(mlat_label)
colormap(gca,colorcet(clm.t))
clb = colorbar;
clb.Label.String = ['T_i [',unt.t,']'];
clb.Ruler.TickLabelFormat = clb_fmt;
clb.Ruler.Exponent = clb_exp;
clim(Ti_range_p)
xline(mlon_rac_p,'r--')

if ~exist(fullfile(plotdirec,'plots',folder),'dir')
	mkdir(plotdirec,fullfile('plots',folder));
end
filename = fullfile(plotdirec,'plots',folder,[filename_prefix,'_',suffix,'.png']);
saveas(gcf,filename)
close all
end













