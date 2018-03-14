function  dxdt = sys(t, x, u, model_ss)
    dxdt = model_ss.A * x + model_ss.B * u;    
end