clear; clc; close all;

dbstop if error;


intercept = 620;
assy = 10;

params_two   = [intercept,0.1];

y = [intercept,assy,assy,assy,assy,assy,assy,assy]';

% Now fit the data
X = (1:8)';

modelfun_two_par = @(b,x)b(1) * exp(-b(2) * (x(:,1)-1));

mdl_two_par = fitnlm(X,y,modelfun_two_par,params_two)

plot(mdl_two_par.predict)
hold on
plot(mdl_two_par.Variables.y)

[out_two_params,fval_two_param,exitFlag] = est_learning_rate(y',params_two,0,'two_parameters')

%% Calculate sse for various params
sse = [];

for lr = 0.1:0.1:80
    
    lr

    % Create the fake data
    y_hat = intercept * exp(-lr*(X-1));

    % mse
    sse(length(sse)+1) = nansum(abs(y - y_hat).^2);

end

lr = 0.1:0.1:80

[M,I] = min(sse)

lr_good = lr(I)

plot(sse)
ylim([0,3])

%% Three parameter

params_three = [150,0.1,180];


modelfun_three_par = @(b,x)b(1) * (exp(-b(2) * (x(:,1)-1)) - 1) + b(3);

mdl_three_par = fitnlm(X,y,modelfun_three_par,params_three)

close 
plot(mdl_three_par.predict)
hold on
plot(mdl_three_par.Variables.y)