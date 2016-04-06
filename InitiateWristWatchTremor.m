l = 1;
loc = 'C:\Users\labuser\Documents\GENEActiv\Data\LA__026357_2016-03-23 13-23-33.csv';
row = 59;
starttime = [];
endtime = [];

WRT = WristWatchTremor(l,loc,row,starttime,endtime);
WRT.LoadAcc;