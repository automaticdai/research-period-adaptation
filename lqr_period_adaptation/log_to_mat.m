
for Ti = 1000:100:2000
	filename = ['./logs/log' num2str(Ti) '.log'];
	csv_data_all = csvread(filename);

	Tss_t = csv_data_all(:,2);
	pi.Tss = Tss_t(Tss_t ~= 0);

	ISE_t = csv_data_all(:,3);
	pi.ISE = ISE_t(ISE_t ~= 0);

	IAE_t = csv_data_all(:,4);
	pi.IAE = IAE_t(IAE_t ~= 0);

	ri_t = csv_data_all(:,5);
	ri = ri_t(ri_t ~= 0);

	filename = ['./logs/pi_afbs_' num2str(Ti) 'ms'];
	save([filename '.mat'], 'pi')

	%filename = ['ri_afbs_' num2str(Ti) 'ms'];
	%save([filename '.mat'], 'ri')
end