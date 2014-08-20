% load info from cruise_info
allsettings = add_cruise_info;

% die hier eintragen
allsettings.sbepre_filename = 'msm_022_1_';
allsettings.lonlat = [-27 -20 -5 20];   %[lonmin,lonmax,latmin,latmax] for cruise map
allsettings.area = '23w';

% msm_022_1_settings.m
% settings for CTD calibration
allsettings.release = 3;
allsettings.quality_control_indicator = '5';
allsettings.quality_index = 'A';
allsettings.uncertainty.t = 0.002;
allsettings.uncertainty.s = 0.002;
allsettings.uncertainty.p = 2;
allsettings.uncertainty.o = 1;

allsettings.loopedit = 0.01;
allsettings.use_system_upload_time = 0;

allsettings.start_scan = [];
% override start_scan of profiles (determined in step 1)
% enter pairs [profile_number,first_good_scan]

allsettings.aligndepthrange = [400,1400];
allsettings.alignsigns = [1,-1];		% for C and for O
allsettings.addname = 's1s2s3s4s5';
allsettings.print_format = 'jpg';

allsettings.author = 'Gerd Krahmann';
allsettings.contact = 'gkrahmann@geomar.de';

allsettings.comment = '';
allsettings.references = '';

allsettings.do_not_write_down_data_write_up_in_down_file_instead = [];
allsettings.do_not_write_up_file = 7;
allsettings.down_is_up = [];
allsettings.use_davis_nav = [];  % This should be empty and
                                      % is only used for station 54 and 55
                                      % of MSM182, where NMEA was
                                      % not recorded in .cnv file

% load sensor SNs and create settings
if ~exist(['mat/',allsettings.crsid,'_sensors.mat'])
  sensor = get_sensors(allsettings.crsid);
  load(['mat/',allsettings.crsid,'_sensors.mat'])
else
  load(['mat/',allsettings.crsid,'_sensors.mat'])
end

%%% for CALIBRATION STEPS 1-8 (to be commented out for STEPS 9-15) 
% comment this later, this is used
% to force the routine to calibrate these
% profiles as one setting
% use the calibration coefficients C down/up secondary
% from this calculation
% and apply them with set_cal to secondary settings
% 1,2
if 0   % run this to determine C down/up calc string for secondary setting 1,2
  load(['mat/',allsettings.crsid,'_sensors.mat'])
  bad_sec = find(sensor.sec_setup<3);
  sensor.sec_setup(bad_sec) = 1;
  save(['mat/',allsettings.crsid,'_sensors.mat'],'sensor')
end
% set all primary to one setting
if 0   % run this to determine C down/up calc string for secondary setting 1,2
  load(['mat/',allsettings.crsid,'_sensors.mat'])
  bad_pri = find(sensor.pri_setup<100);
  sensor.pri_setup(bad_pri) = 1;
  save(['mat/',allsettings.crsid,'_sensors.mat'],'sensor')
end

pri = unique(sensor.pri_setup);
pri = pri(find(~isnan(pri)));
sec = unique(sensor.sec_setup);
sec = sec(find(~isnan(sec)));
ctd = unique(sensor.ctd_setup);
ctd = ctd(find(~isnan(ctd)));

for n=1:length(pri)
  pri_settings(pri(n)).prof = sensor.prof(find(pri(n)==sensor.pri_setup));
  pri_settings(pri(n)).apply2prof = sensor.prof(find(pri(n)==sensor.pri_setup));
  pri_settings(pri(n)).o_std = 0.33;               
  pri_settings(pri(n)).o_meth = 'f'; 
  pri_settings(pri(n)).o_exps = [2,1,0,1,0,0];   
  pri_settings(pri(n)).c_std = 0.33;               
  pri_settings(pri(n)).c_meth = 'f'; 
  pri_settings(pri(n)).c_exps = [1,1,1,0,0,0];   
  pri_settings(pri(n)).c_exps = [1,1,1,0,1,0];   
  pri_settings(pri(n)).corr_hyst = 'off';   
end
for n=1:length(sec)
  sec_settings(sec(n)).prof = sensor.prof(find(sec(n)==sensor.sec_setup));
  sec_settings(sec(n)).apply2prof = sensor.prof(find(sec(n)==sensor.sec_setup));
  sec_settings(sec(n)).o_std = 0.33;               
  sec_settings(sec(n)).o_meth = 'f'; 
  sec_settings(sec(n)).o_exps = [2,1,0,1,0,0];   
  sec_settings(sec(n)).c_std = 0.33;               
  sec_settings(sec(n)).c_meth = 'f'; 
  sec_settings(sec(n)).c_exps = [1,1,1,0,0,0];   
  sec_settings(sec(n)).corr_hyst = 'off';   
end
for n=1:length(ctd)
  ctd_settings(ctd(n)).prof = sensor.prof(find(ctd(n)==sensor.ctd_setup));
  ctd_settings(ctd(n)).apply2prof = sensor.prof(find(ctd(n)==sensor.ctd_setup));
  ctd_settings(ctd(n)).p_offset = 0;               
end

% force the following calibration strings
if 0
set_cal(1).c_up_sec_str = '0.0012488+4.8444e-08*p+2.8793e-05*t-0.00040067*c-4.3883e-05*tim';
set_cal(1).c_down_sec_str = '-0.0052653-1.1224e-07*p-0.00022574*t+0.0019932*c-4.7121e-05*tim';
set_cal(2).c_up_sec_str = '0.0012488+4.8444e-08*p+2.8793e-05*t-0.00040067*c-4.3883e-05*tim';
set_cal(2).c_down_sec_str = '-0.0052653-1.1224e-07*p-0.00022574*t+0.0019932*c-4.7121e-05*tim';
end
if 0
set_cal(1).c_up_sec_str = '0';
set_cal(1).c_down_sec_str = '0';
set_cal(2).c_up_sec_str = '0';
set_cal(2).c_down_sec_str = '0';
set_cal(1).c_up_pri_str = '0';
set_cal(1).c_down_pri_str = '0';
set_cal(2).c_up_pri_str = '0';
set_cal(2).c_down_pri_str = '0';
end
if 0
set_cal(1).c_up_pri_str = '0.0025993+4.2749e-08*p+9.1335e-05*t-0.00089737*c';
set_cal(1).c_down_pri_str = '-0.00042022-2.1438e-08*p-1.7445e-05*t+0.00018159*c';
set_cal(2).c_up_pri_str = '0.0025993+4.2749e-08*p+9.1335e-05*t-0.00089737*c';
set_cal(2).c_down_pri_str = '-0.00042022-2.1438e-08*p-1.7445e-05*t+0.00018159*c';
end
if 1
set_cal(1).c_up_pri_str = '-0.0031753-7.7086e-08*p-0.00013348*t+0.0012389*c-1.5069e-05*tim';
set_cal(1).c_down_pri_str = '-0.0036198-9.8582e-08*p-0.00014601*t+0.00141*c-1.5779e-05*tim';
set_cal(2).c_up_pri_str = '-0.0031753-7.7086e-08*p-0.00013348*t+0.0012389*c-1.5069e-05*tim';
set_cal(2).c_down_pri_str = '-0.0036198-9.8582e-08*p-0.00014601*t+0.00141*c-1.5779e-05*tim';
end


% insert 'median' from final plot in step 1
% this will remove deck pressure

ctd_settings(1).p_offset = 1.18;
ctd_settings(1).chl_offset = 0.029;
ctd_settings(1).chl2_offset = 0;
ctd_settings(1).turb_offset = 0;

% second set of sensors was generally better
% during profiles 42 to 56 the oxygen of string 2 went bad
% and we tried different configurations
% after 57 it was good again
if 0
use_settings(1).apply2prof = [1:41];
use_settings(1).use_sensor = [2,2,2];
use_settings(2).apply2prof = [42:56];
use_settings(2).use_sensor = [1,1,1];
use_settings(3).apply2prof = [57:80,82:115];
use_settings(3).use_sensor = [2,2,2];
elseif 0
use_settings(1).apply2prof = [1:80,82:115];
use_settings(1).use_sensor = [1,1,1];
else
use_settings(1).apply2prof = [1:8,32:41];
use_settings(1).use_sensor = [1,1,2];
use_settings(2).apply2prof = [9:31,42:80,82:115];
use_settings(2).use_sensor = [1,1,1];
end

allsettings.yoyos = [106];

% profiles 1 to 8 primary oxygen sensor bad, replaced between 8 and 9
% profiles 42 to 46 secondary oxygen sensor bad
% no profile 81 was recorded
% profiles 105, 106, and 107 are all stored in file 105
% this file has been copied to 106 and 107 and lines that do not
% belong to the subprofiles are removed from the cnv file


%allsettings.stick_voltage_number_into_haardtc = 5;

% what to set for sensor calibration
%  _f = 's' for outlier selection by std criterion (in _std)
%  _f = 'f' for outlier selection by fraction of data criterion (in _std)
%  _exps =   degree of polynom in [press, temp, cond, oxyf, time,chl]
 
% which variables to write into calibrated files
% choose from
% p          pressure
% z          depth
% t          in situ temperature
% s          salinity
% o          oxygen in umol/kg
% chl_raw    Dr. Haardt chlorophyl in raw uncorrected ug/l
% chl2_raw   Wetlabs chlorophyl in raw uncorrected ug/l
% turb_raw   Wetlabs turbidity in raw uncorrected NTU
% c          conductivity
% sig        in situ density
% ss         sound speed
% sth        sigma theta
% tim        time in Matlab datenum units
allsettings.write_prof_vars = {'tim','p','z','t','s','o','ss','sth','chl_raw','voltage6'};
allsettings.write_time_vars = {'tim','p','t','s','c','o','chl_raw'};

% btl_down 1: pressure only;(fastest) 2: pressure and closest temperature
%          3: best vertical shift of up temperature profile (slow but good)
allsettings.btl_down = 2; 
allsettings.btl_down_tshift = [1,50];   % delta p for shift, prange for shift
allsettings.btl_down_sensor = 2;  % use primary or secondary to pick
                                  % down bottle equivalents

allsettings.bad_profiles=[];                    
                   
%
% define which calibrated rodbfiles are to be written
% give a vector of the types
%
% 1: regular 1 dbar file
% 2: upcast 1 dbar file
% 3: 1 second binned full cast file
% 4: full data rate full cast file
allsettings.which_file_types = [4];
allsettings.which_file_types = [1,2,3];



% mark bad scans
allsettings.bad_c_1_scans = [[37,14650,23065];[38,172520,172530];[38,172550,172560];...
  [38,178760,178770];[38,190780,190795];[38,178755,178775];[40,53000,58700]];
allsettings.bad_c_2_scans = [[37,14650,23065];[38,112650,112670];[38,172500,172510];...
  [44,77790,77825];[44,78285,78320];[44,79050,79115];[44,79370,79375];[44,79385,79390];...
  [44,79405,79410];[44,79433,79437];[44,79446,79450];[44,80095,80135];[44,81960,81980];...
  [44,82075,82140];[44,82415,82420];[44,84755,84780];[44,85840,85900];[44,86150,86160];...
  [38,112640,112680]];
%allsettings.bad_t_1_scans = [[4,68000,122000];[47,14550,14935];[68,211498,211499];[76,7724,7730]];
%allsettings.bad_t_2_scans = [[47,12570,12700];[47,12740,12900];[47,13060,13060];[47,14005,14010];[47,15048,15048]];
allsettings.bad_o_1_scans = [[38,14580,14640];[38,16750,16810];[38,20060,20130];...
  [38,33010,33070];[38,46550,46610];[38,56000,70000];[38,91000,98000];...
  [38,128160,128230];[38,143520,143590];[38,144820,144880];[38,161640,161780];...
  [38,177900,178000];[38,178840,178920];[38,178750,178770];[38,183520,183600];...
  [38,188540,188600];[38,188720,188790];[38,189620,189680];[38,204700,205800];...
  [38,224700,227000];[40,52500,231244]];
allsettings.bad_o_2_scans = [[38,21720,21780];[38,51970,52030];[38,98140,98210];...
  [38,98900,98960];[38,112650,112660];[38,131320,131380];[38,139550,139650];...
  [38,142910,142970];[38,144020,144080];[38,160200,160260];[38,161530,161590];...
  [38,163070,163130];[38,164040,164110];[38,165460,165510];[38,166020,166090];...
  [38,169900,169960];[38,177650,177900];[38,178840,178920];[38,183170,183350];...
  [38,188390,188460];[38,189620,189680];[38,190140,190200];[42,1,251434];...
  [38,112550,112610];[43,1,230885];[44,1,228701];[45,1,24169];[46,1,224510];[47,1,22410];[48,1,207793];...
  [49,1,133755];[50,1,21894];[51,1,242998];[52,1,188692];[53,1,222787];[54,1,21122];[55,1,257909];...
  [56,1,267923];[57,1,23107]];

allsettings.tsal.remove_frac_s1 = 10;
allsettings.tsal.remove_frac_s2 = 10;
allsettings.tsal.remove_frac_t1 = 10;
allsettings.tsal.remove_frac_t2 = 10;
allsettings.tsal.remove_frac_t3 = 10;
allsettings.tsal.remove_frac_t4 = 10;
allsettings.tsal.remove_frac_chl1 = 10;
allsettings.tsal.remove_frac_chl2 = 10;
