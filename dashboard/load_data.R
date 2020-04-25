library(dplyr)
library(DBI)
library(sys)
library(stringr)
library(tidyverse)
library(sf)
library(civis)




neighborhood_councils <- sf::st_read(
  "../data/neighborhood_council_boundaries.geojson"
)

council_districts <- sf::st_read(
  "https://opendata.arcgis.com/datasets/76104f230e384f38871eb3c4782f903d_13.geojson"
)

lapd_divisions <- sf::st_read(
  "https://opendata.arcgis.com/datasets/031d488e158144d0b3aecaa9c888b7b3_0.geojson"
)

latimes_neighborhoods <- sf::st_read(
  "http://boundaries.latimes.com/1.0/boundary-set/la-county-neighborhoods-current/?format=geojson"
)

# CORONAVIRUS 

coronavirus_deaths <- read_csv(
  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"
)
coronavirus_cases <- read_csv(
  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
)

county_boundary <- sf::st_read('../data/la_county.geojson')

state_boundary <- sf::st_read('../data/state-boundary.geojson')

  
my_table <- "scratch.homelessness_cases_311"

load_data <- function() {
  data <- read_civis(my_table, 
                     database="City of Los Angeles - Postgres")
  
  data$closeddate <- as_date(data$closeddate, "%m/%d/%Y") 
  #above not working replaced with s striptime function 
  #data$ClosedDate <- strptime(data$ClosedDate, "%m/%d/%Y %H:%M:%S", tz='America/Los_Angeles').cast()
  
  data <- data %>% filter(!is.na(closeddate)) #drops all open cases, but seems to not actually be dropping anything
  
    #' This script loads the data files and ensures the correct data types are used
  
  # column names with proper spacing / underscores 
  col_names_311 <- c(
    "srn_number", "created_date", "updated_date", "action_taken",
    "owner", "request_type", "status", "request_source",
    "mobile_os", "anonymous", "assign_to", "service_date",
    "closed_date", "address_verified", "approximate_address",
    "address", "house_number", "direction", "street_name",
    "suffix", "zipcode", "latitude", "longitude", "location",
    "thompson_brothers_map_page", "thompson_brothers_map_column",
    "thompson_brothers_map_row", "area_planning_commissions",
    "council_district", "city_council_member",
    "neighborhood_council_code", "neighborhood_council_name",
    "police_precinct"
  )
  
  data <- data %>% 
           select(-c('index')) %>%
           rename(
                  'action_taken' = 'actiontaken',
                  'address_verified' = 'addressverified',
                  'approximate_address' = 'approximateaddress',
                  'assign_to' = 'assignto',
                  'council_district' = 'cd',
                  'cd_member' = 'cdmember',
                  'closed_date' = 'closeddate',
                  'created_by_user_organization' = 'createdbyuserorganization',
                  'created_date' = 'createddate',
                  'date_service_rendered' = 'dateservicerendered',
                  'house_number' = 'housenumber',
                  'mobile_os' = 'mobileos',
                  'neighborhood_council_name' = 'ncname',
                  'police_precinct' = 'policeprecinct',
                  'reason_code' = 'reasoncode',
                  'request_source' = 'requestsource',
                  'request_type' = 'requesttype',
                  'resolution_code' = 'resolutioncode', 
                  'service_date' = 'servicedate',
                  'service_request_number' = 'srnumber',
                  'street_name' = 'streetname',
                  'updated_date' = 'updateddate'
                   )
  # data$closed_date <- data$closed_date %>% as_datetime()
  # data$created_date <- data$created_date %>% as_datetime()
  
  # only load 2016 to present.  
  data <- data %>% filter(created_date > '2016-01-01')
  return(data)
}

summarize_cleanstat <- function() {
  cleanstat <- read_civis("public_health.cleanstat","City of Los Angeles - Postgres") %>%
    filter(Year ==  "2018") %>%
    filter(Quarter == "Q3") 
}
