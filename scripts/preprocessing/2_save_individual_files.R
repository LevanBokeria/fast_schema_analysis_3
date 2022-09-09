# Description ############################

# This script will load the group data file downloaded from JATOS, find the 
# 'data submission' modules for each participant, and save those as separate
# RData files. Prolific IDs are substituted with sub_00* strings.

# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')


file_location <- 'jatos_gui_downloads'

# Start reading the files ##################

# Get the file mapping prolific IDs with randID
prol_to_rand <- read_csv(paste0('../../../',
                                Sys.getenv("USERNAME"),
                                '/ownCloud/Cambridge/PhD/projects/fast_schema_mapping_decoupling_distraction/prolific_metadata/prol_id_to_rand_id.csv'))

# Get a list of all files in the folder
incoming_files <- list.files(paste0('./data/incoming_data/',file_location,'/'))

# Alternatively, specify the file name
incoming_files <- c('jatos_results_13.txt')

prol_ids <- c()

for (iFile in incoming_files){
        
        print(iFile)
        
        # Parse it
        my_data <- read_file(paste0('./data/incoming_data/',file_location,'/',iFile))
        
        # Find the data submission module
        start_loc <- str_locate_all(my_data, 'data_submission_start---')[[1]]
        end_loc   <- str_locate_all(my_data, '---data_submission_end]')[[1]]
        
        for (iPtp in seq(nrow(start_loc))){
                
                json_content <- substr(my_data,start_loc[iPtp,2]+1,end_loc[iPtp,1]-1)
                
                json_decoded <- fromJSON(json_content)
                
                print(json_decoded$prolific_ID)  
                
                # If its 62cc3a6cddb99927e3c62fb9, manually add the debriefing component
                # For some reason, this did not get saved in the studySessionData.outputData
                if (json_decoded$prolific_ID == '62cc3a6cddb99927e3c62fb9'){
                        
                        # Find the debriefing component
                        start_loc_deb <- str_locate_all(my_data, 'debriefing_start_---')[[1]]
                        end_loc_deb   <- str_locate_all(my_data, '---_debriefing_end]')[[1]]
                        
                        json_content_deb <- substr(my_data,start_loc_deb[iPtp,2]+1,end_loc_deb[iPtp,1]-1)
                        
                        json_decoded_deb <- fromJSON(json_content_deb)
                        
                        json_decoded_deb <- json_decoded_deb[1,]
                        
                        json_decoded_deb <- json_decoded_deb %>%
                                select(response)
                        
                        json_decoded_deb <- do.call(data.frame,json_decoded_deb)
                        
                        json_decoded_deb <- json_decoded_deb %>%
                                rename(Q0 = response.Q0,
                                       Q1 = response.Q1,
                                       Q2 = response.Q2,
                                       Q3 = response.Q3,
                                       Q4 = response.Q4,
                                       Q5 = response.Q5,
                                       Q6 = response.Q6,
                                       Q7 = response.Q7)
                        
                        # Now, add this to the output
                        json_decoded$outputData$debriefing$response <- json_decoded_deb
                }
                
                # Find the rand_id of this person
                iRand_id <- prol_to_rand$rand_id[prol_to_rand$prol_id == json_decoded$prolific_ID]
        
                
                # Re-decode the content
                json_decoded$prolific_ID <- iRand_id
                
                # Save the data submission module output
                export(json_decoded,paste0('./data/',iRand_id,'.RDS'))
                
                print(paste0('Saved ', json_decoded$prolific_ID))
                
        }        
        
        
}