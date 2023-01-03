rm(list=ls())


source('./scripts/utils/load_all_libraries.R')


# Load dataframes #################


metadata <- import('../../ownCloud/Cambridge/PhD/projects/fast_schema_mapping_decoupling_distraction/prolific_metadata/prolific_export_61eaa76993a8019d2856be3d.csv')

pid_map <- import('../../ownCloud/Cambridge/PhD/projects/fast_schema_mapping_decoupling_distraction/prolific_metadata/prol_id_to_rand_id.csv')

qc_table <- import('./results/qc_check_sheets/qc_table.csv')

# Sanity checks ####################


# Does everyone in metadata that was approved have a qc table entry?

ptp_approved <- metadata[metadata$Status != 'RETURNED','Participant id']

ptp_approved[which(ptp_approved %in% pid_map$prol_id == F)]

# Two people, one rejected so ok that we don't analyze
# The second one, I'm not sure why I did not analyze. 

# Does everyone in qc and pid map have a prolific entry?
which(pid_map$prol_id %in% metadata$`Participant id` == F)
# Yes they do


metadata_approved <- metadata %>%
        filter(Status != 'RETURNED')

# Join pid map and qc table
pid_qc <- merge(pid_map,qc_table,
                by.x = 'rand_id',
                by.y = 'ptp')

# Now merge the metadata and pid qc

pid_qc_metadata <- merge(pid_qc,metadata_approved,
                         by.x = 'prol_id',
                         by.y = 'Participant id',
                         all.y = T)

# Remove those that revoked consent
pid_qc_metadata <- pid_qc_metadata %>%
        filter(Vision != 'CONSENT_REVOKED')

# Now do the summary stats ########################################

# Total number of people 
pid_qc_metadata %>%
        count(Sex)

pid_qc_metadata %>%
        filter(Age != 'DATA_EXPIRED') %>%
        mutate(Age = as.numeric(Age)) %>% 
        summarise(mean_age = mean(Age),
                  max_age = max(Age),
                  min_age = min(Age),
                  sd_age = sd(Age))

# Now juts qc pass
pid_qc_metadata %>%
        filter(qc_fail_overall == 'FALSE') %>%
        count(Sex)


pid_qc_metadata %>%
        filter(Age != 'DATA_EXPIRED') %>%
        filter(qc_fail_overall == 'FALSE') %>%
        mutate(Age = as.numeric(Age)) %>% 
        summarise(mean_age = mean(Age),
                  max_age = max(Age),
                  min_age = min(Age),
                  sd_age = sd(Age))
