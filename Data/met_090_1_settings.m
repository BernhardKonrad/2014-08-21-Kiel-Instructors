% load info from cruise_info
allsettings = add_cruise_info;

% die hier eintragen
allsettings.sbepre_filename = 'm_90_';
allsettings.lonlat = [-95 -70 -20 7];   %[lonmin,lonmax,latmin,latmax] for cruise map


% met_090_1_settings.m
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

allsettings.area = 'pac'; 
allsettings.aligndepthrange = [400,1400];
allsettings.alignsigns = [1,-1];		% for C and for O
allsettings.addname = 's1s2s3s4s5';
allsettings.print_format = 'jpg';

allsettings.author = 'Gerd Krahmann';
allsettings.contact = 'gkrahmann@geomar.de';

allsettings.comment = 'CTD data from stations 1 and 2 were measured with a different CTD system. This data has a significantly higher uncertainty because the limited calibration. >0.01 PSU and >5 mumol/kg, respectively.  Please use this data with caution.  Please also note that the calibration with Winkler titration might have problems with low oxygen values. Reported CTD oxygen values lower than 3 mumol/kg might actually be lower. Possibly even near 0 mumol/kg. Please use this data with caution.';
allsettings.references = '';

allsettings.do_not_write_down_data_write_up_in_down_file_instead = [];
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
  pri_settings(pri(n)).o_exps = [1,1,0,1,0,0];   
  pri_settings(pri(n)).c_std = 0.33;               
  pri_settings(pri(n)).c_meth = 'f'; 
  pri_settings(pri(n)).c_exps = [1,1,1,0,0,0];   
  pri_settings(pri(n)).corr_hyst = 'off';   
end
for n=1:length(sec)
  sec_settings(sec(n)).prof = sensor.prof(find(sec(n)==sensor.sec_setup));
  sec_settings(sec(n)).apply2prof = sensor.prof(find(sec(n)==sensor.sec_setup));
  sec_settings(sec(n)).o_std = 0.33;               
  sec_settings(sec(n)).o_meth = 'f'; 
  sec_settings(sec(n)).o_exps = [1,1,0,1,0,0];   
  sec_settings(sec(n)).c_std = 0.33;               
  sec_settings(sec(n)).c_meth = 'f'; 
  sec_settings(sec(n)).c_exps = [1,1,1,0,0,0];   
  sec_settings(sec(n)).corr_hyst = 'off';   
end
for n=1:length(ctd)
  ctd_settings(ctd(n)).prof = sensor.prof(find(ctd(n)==sensor.ctd_setup));
  ctd_settings(ctd(n)).apply2prof = sensor.prof(find(ctd(n)==sensor.ctd_setup));
  ctd_settings(ctd(n)).p_offset = 0;
  ctd_settings(ctd(n)).chl_offset = 0;               
end

% use all data for this calibration
% as we have only 2 stations
sec_settings(1).c_std = 0;
sec_settings(1).o_std = 0;

%set_cal(1).c_down_sec_str = '-0.0061039+1.0304e-06*p+0.00025692*t+0.0012315*c';
set_cal(1).c_down_sec_str = '0';
%set_cal(1).o_down_sec_str = '14.379-0.033726*p-1.0149*t+2.1689*o';


% insert 'median' from final plot in step 1
% this will remove deck pressure

ctd_settings(1).p_offset = 0.005;
ctd_settings(2).p_offset = -1.09;

ctd_settings(1).chl_offset = 0;
ctd_settings(1).chl2_offset = 0.0075;
ctd_settings(1).turb_offset = 0.0085;

ctd_settings(2).chl_offset = 0;
ctd_settings(2).chl2_offset = -0.0005;
ctd_settings(2).turb_offset = 0.007;


ctd_settings(1).apply2prof = [1:2];
ctd_settings(2).apply2prof = [3:184];

% 965 is second half of 64. Merged with merge_broken into 64
use_settings(1).apply2prof = [[1:184]];
use_settings(1).use_sensor = [2,2,2];

allsettings.stick_voltage_number_into_haardtc = 0;

%allsettings.rinko_channel_1 = 5;
%allsettings.rinko_channel_2 = 6;
%allsettings.rinko_serial_no = 54;


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
allsettings.write_prof_vars = {'tim','p','z','t','s','o','ss','sth','chl2_raw','turb_raw','par','spar'};
allsettings.write_time_vars = {'tim','p','t','s','c','o','chl2_raw'};

% btl_down 1: pressure only;(fastest) 2: pressure and closest temperature
%          3: best vertical shift of up temperature profile (slow but good)
allsettings.btl_down = 2; 
allsettings.btl_down_tshift = [1,50];   % delta p for shift, prange for shift
allsettings.btl_down_sensor = 1;  % use primary or secondary to pick
                                  % down bottle equivalents

%allsettings.bad_profiles=[1;2];                    
                   
%
% define which calibrated rodbfiles are to be written
% give a vector of the types
%
% 1: regular 1 dbar file
% 2: upcast 1 dbar file
% 3: 1 second binned full cast file
% 4: full data rate full cast file
allsettings.which_file_types = [1,2,3];

allsettings.yoyo = [];


%% Comment NM:
%Startscan for Profile 118 was set manually to 15800, as program determined
%it wrong
%%


% mark bad scans
allsettings.bad_c_1_scans = [[1,41300,106150];[2,1,152196]];
allsettings.bad_t_1_scans = [[1,41300,106150];[2,1,152196]];
allsettings.bad_o_1_scans = [[1,41300,106150];[2,1,152196]];

