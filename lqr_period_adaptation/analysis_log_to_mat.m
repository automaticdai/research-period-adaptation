
Ti = 19;
filename = ['log_' num2str(Ti) 'ms'];
csv_data_all = csvread([filename '.txt']);

Tss_t = csv_data_all(:,2);
pi.Tss = Tss_t(Tss_t ~= 0);

ISE_t = csv_data_all(:,3);
pi.ISE = ISE_t(ISE_t ~= 0);

IAE_t = csv_data_all(:,4);
pi.IAE = IAE_t(IAE_t ~= 0);

ri_t = csv_data_all(:,5);
ri = ri_t(ri_t ~= 0);


filename = ['pi_afbs_' num2str(Ti) 'ms'];
save([filename '.mat'], 'pi')

filename = ['ri_afbs_' num2str(Ti) 'ms'];
save([filename '.mat'], 'ri')
