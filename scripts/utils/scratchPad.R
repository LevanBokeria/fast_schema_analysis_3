rm(list=ls())

source('./scripts/utils/load_all_libraries.R')

# Load
qc_filter <- T

source('./scripts/utils/load_transform_data.R')

qc_table <- import('./results/qc_check_sheets/qc_table.csv')

# Load matlab fits
ml_learning_rate <- import('./results/learning_rate_fits_matlab.csv')


if (qc_filter){
        
        qc_pass_ptp <- qc_table %>%
                filter(!qc_fail_overall) %>%
                select(ptp) %>% .[[1]]
        
        
        data_summary <- data_summary %>%
                filter(ptp %in% qc_pass_ptp)
        long_data <- long_data %>%
                filter(ptp %in% qc_pass_ptp) 
        mean_by_rep_long_all_types <- mean_by_rep_long_all_types %>%
                filter(ptp %in% qc_pass_ptp)
        
        ml_learning_rate <- ml_learning_rate %>%
                filter(ptp %in% qc_pass_ptp)
        
}




# Plots #####################

## 2 param ---------------------

ml_learning_rate %>%
        ggplot(aes(x=fminsearch_two_param_1,y=intercept_two_param)) +
        geom_point()

ml_learning_rate %>%
        ggplot(aes(x=fminsearch_two_param_2,y=learning_rate_two_param)) +
        geom_point()

## 3 param ---------------------
ml_learning_rate %>%
        ggplot(aes(x=fminsearch_three_param_1,y=intercept_three_param)) +
        geom_point() +
        geom_abline(slope = 1, color = 'red') +
        facet_wrap(~hidden_pa_img_type)

ml_learning_rate %>%
        ggplot(aes(x=fminsearch_three_param_2,y=learning_rate_three_param)) +
        geom_point() +
        geom_abline(slope = 1, color = 'red') +
        facet_wrap(~hidden_pa_img_type) 
+ 
        coord_cartesian(ylim = c(0,100))

ml_learning_rate %>%
        ggplot(aes(x=fminsearch_three_param_1-fminsearch_three_param_3,y=asymptote_three_param)) +
        geom_point() +
        geom_abline(slope = 1, color = 'red') +
        facet_wrap(~hidden_pa_img_type) 
+ 
        coord_cartesian(xlim = c(-100,200), ylim = c(-100,200))



ml_learning_rate <- ml_learning_rate %>%
        mutate(which_model = case_when(
                AIC_two_param < AIC_three_param ~ 'two',
                AIC_two_param > AIC_three_param ~ 'three',
                TRUE ~ 'equal'
        ))

ml_learning_rate %>% count(which_model)

ml_learning_rate %>%
        ggplot(aes(x=AIC_two_param,y=AIC_three_param)) +
        # ggplot(aes(x=BIC_two_param,y=BIC_three_param)) +
        geom_point() +
        geom_abline(slope = 1,intercept = 0) + 
        coord_cartesian(xlim = c(40,100),ylim = c(40,100)) +
        facet_wrap(~hidden_pa_img_type)

ml_learning_rate %>%
        ggplot(aes(x=sse_two_param,y=sse_three_param)) +
        # ggplot(aes(x=BIC_two_param,y=BIC_three_param)) +
        geom_point() +
        geom_abline(slope = 1,intercept = 0) +
        facet_wrap(~hidden_pa_img_type)


# Get one part data
# exdata <- 
# mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa',
#                ptp == 'sub_001',
#                condition == 'schema_c') %>%
#         select(ptp,
#                hidden_pa_img_row_number_across_blocks,
#                mouse_error_mean)
# 
# 
# mdl <- nls(mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#     data = exdata,
#     start = list(c = 0.1,
#                  a = 200))
# 
# 
# exdata %>% nls(mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                data = .,
#                start = list(c = 0.1,
#                             a = 200))


# Try on grouped data
# mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa') %>%
#         droplevels() %>%
#         group_by(ptp,
#                  condition) %>%
#         summarise(
#                 full_model_two_param = list(nls(
#                         mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                         data = cur_data(),
#                         start = list(c = 0.1,
#                                      a = 200),
#                         control = list(maxiter = 200))),
#                 full_model_three_param = list(nls(
#                         mouse_error_mean ~ b * exp(-c*(hidden_pa_img_row_number_across_blocks-1)) + a - b,
#                         data = cur_data(),
#                         start = list(b = 90,
#                                      c = 0.1,
#                                      a = 100),
#                         control = list(maxiter = 200)))) %>%
#         ungroup()
#         rowwise() %>%
#         mutate(a_two_param = coef(full_model_two_param)['a'],
#                c_two_param = coef(full_model_two_param)['c'],
#                loglik_two_param = as.vector(logLik(full_model_two_param))) %>% View()
# 
# 
# a %>%
#         mutate(cf = coefficients(full_model)['a']) %>% View()
# 
# mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa') %>%
#         droplevels() %>%
#         group_by(ptp,
#                  condition) %>%
#         summarise(
#                 loglik_two_param = as.vector(logLik(nls(
#                 mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                 data = cur_data(),
#                 start = list(c = 0.1,
#                              a = 200),
#                 control = list(maxiter = 200)))),
#                a = coefficients(nls(
#                        mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                        data = cur_data(),
#                        start = list(c = 0.1,
#                                     a = 200),
#                        control = list(maxiter = 200)))['a'],
#                c = coefficients(nls(
#                        mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                        data = cur_data(),
#                        start = list(c = 0.1,
#                                     a = 200),
#                        control = list(maxiter = 200)))['c'],
#                mdl = nls(
#                        mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                        data = cur_data(),
#                        start = list(c = 0.1,
#                                     a = 200),
#                        control = list(maxiter = 200))$convInfo$isConv
#                ) %>%
#         ungroup() %>% View()


# for (iptp in unique(mean_by_rep_long_all_types$ptp)){
#         
#         for (icond in unique(mean_by_rep_long_all_types$condition)){
#                 
#                 
#                 curr_data <- mean_by_rep_long_all_types %>%
#                         filter(border_dist_closest == 'all',
#                                hidden_pa_img_type == 'all_pa',
#                                ptp == iptp,
#                                condition == icond) 
#                 
#                 print(iptp)
#                 print(icond)
#                 
#                 mdl <- nls(mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                            data = curr_data,
#                            start = list(c = 0.1,
#                                         a = 200),
#                            control = list(maxiter = 2000))
#                 
#                 mdl2 <- nls(
#                         mouse_error_mean ~ b * exp(-c*(hidden_pa_img_row_number_across_blocks-1)) + a - b,
#                         data = curr_data,
#                         start = list(b = 190,
#                                      c = 1,
#                                      a = 200),
#                         control = list(maxiter = 20000,
#                                        minFactor = 1e-15,
#                                        warnOnly = F))
#                 
#                 
#                 print(logLik(mdl))
# 
#                 
#         }
#         
#         
#         
#         
#         
# }


# mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa',
#                ptp %in% c('sub_001','sub_002'),
#                condition == 'schema_c') %>%
#         droplevels() %>%
#         group_by(ptp) %>%
#         nlsList(model = mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                 data = cur_data(),
#                 start = list(c = 0.1,
#                              a = 200),
#                 )
#         
# 
# gd <- mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa',
#                ptp %in% c('sub_001','sub_002')) %>%
#         droplevels()
# 
# nlsList(model = mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)) | ptp/condition,
#         data = gd,
#         start = list(c = 0.1,
#                      a = 200)) -> a
# 
#         
#         group_by(ptp,
#                  counterbalancing,
#                  condition) %>%
#         # summarise(n = n()) %>% View()
#         mutate(loglik_two_param = logLik(nls(
#                 mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                 data = .,
#                 start = list(c = 0.1,
#                              a = 200)
#         ))) %>% ungroup() %>% View()
# 
# 
# 
# nls_table(df = exdata,
#           model = mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#           mod_start = c(c = 0.1,a = 200),
#           output = 'table'
#           ) %>% View()
