# Description ############################

# This code loads the batch data downloaded from JATOS, and extracts prolific 
# IDs, so then I can manually assign random IDs to them and substitute them
# in the data files.

# 1. Download the data from JATOS.
# 2. Run this code.
# 3. Manually copy to prolific IDs into the prol_id_to_rand_id.csv file, and 
# assign new random IDs.
# 4. Run 2_save_individual_files.R code.


# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')

# Start reading the files ##################

# Get a list of all files in the folder
incoming_files <- list.files('./data/incoming_data/jatos_gui_downloads/')

incoming_files <- c('jatos_results_12.txt')

prol_ids <- c()

for (iFile in incoming_files){
        
        print(iFile)
        
        # Parse it
        my_data <- read_file(paste0('./data/incoming_data/jatos_gui_downloads/',iFile))
        
        # Find the data submission module
        start_loc <- str_locate_all(my_data, 'data_submission_start---')[[1]]
        end_loc   <- str_locate_all(my_data, '---data_submission_end]')[[1]]
        
        # If no data submission module, skip
        if (is.na(start_loc)){
                
                print(print0('No data submission module. Skipping file',
                             iFile))
                next
                
        } else {
                
                
                for (iPtp in seq(nrow(start_loc))){
                        
                        json_content <- substr(my_data,start_loc[iPtp,2]+1,end_loc[iPtp,1]-1)
                        
                        json_decoded <- fromJSON(json_content)
                        
                        print(json_decoded$prolific_ID)  
                        
                        prol_ids <- append(prol_ids,json_decoded$prolific_ID)      
                        
                        
                }
          
                
        }

}

# Automatically append to the prol id file and generate sub IDs

prol_id_file <- import(paste0('../../../',
                              Sys.getenv("USERNAME"),
                              '/ownCloud/Cambridge/PhD/projects/fast_schema_mapping_decoupling_distraction/prolific_metadata/prol_id_to_rand_id.csv'))

# Check they don't share IDS first
if (any(prol_id_file$prol_id %in% prol_ids)){
        
        stop('IDs already assigned')
}

# Whats the last sub ID?
last_sub_id <- prol_id_file$rand_id[nrow(prol_id_file)]

last_sub_id_num <- parse_number(last_sub_id)

prol_ids <- as.data.frame(prol_ids) %>%
        rename(prol_id = prol_ids) %>%
        mutate(experiment = 1,
               rand_id = NA)

# Now, add sub ids
for (iRow in seq(nrow(prol_ids))){
        
        if (last_sub_id_num < 10){
                
                iID <- paste0('sub_00',last_sub_id_num+iRow)
                
        } else if (last_sub_id_num < 100){
                
                iID <- paste0('sub_0',last_sub_id_num+iRow)
                
        } else {
                
                iID <- paste0('sub_',last_sub_id_num+iRow)
                
        }
        
        prol_ids$rand_id[iRow] <- iID
        
        
}


prol_id_file <- rbind(prol_id_file,prol_ids)

# Now, save this as a csv file
write_csv(prol_id_file,
          paste0('../../../',
                 Sys.getenv("USERNAME"),
                 '/ownCloud/Cambridge/PhD/projects/fast_schema_mapping_decoupling_distraction/prolific_metadata/prol_id_to_rand_id.csv'))
