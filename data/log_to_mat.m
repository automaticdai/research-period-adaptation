
dataset_path = ['./dataset_d3'];

for Ti = 1000:100:4000
	filename = [dataset_path '/logs/log' num2str(Ti) '.log'];
	csv_data_all = csvread(filename);

	Tss_t = csv_data_all(:,2);
	pi.Tss = Tss_t(Tss_t ~= 0);

	ISE_t = csv_data_all(:,3);
	pi.ISE = ISE_t(ISE_t ~= 0);

	IAE_t = csv_data_all(:,4);
	pi.IAE = IAE_t(IAE_t ~= 0);

    Mp_t = csv_data_all(:,5);
	pi.Mp = Mp_t(Mp_t ~= 0);

    Tp_t = csv_data_all(:,6);
	pi.Tp = Tp_t(Tp_t ~= 0);
    
	bcrti_t = csv_data_all(:,7);
	pi.bcrt = bcrti_t(bcrti_t ~= 0);

    wcrti_t = csv_data_all(:,8);
	pi.wcrt = wcrti_t(wcrti_t ~= 0);
    
	filename = [dataset_path '/afbs/pi_afbs_' num2str(Ti)];
	save([filename '.mat'], 'pi')
end