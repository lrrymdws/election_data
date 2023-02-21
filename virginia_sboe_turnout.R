# -----------------------------------------------------------------------------
# Libraries
# -----------------------------------------------------------------------------
library(tidyverse)
library(googlesheets4)
library(bigrquery)
# -----------------------------------------------------------------------------
# Democratic Primary Turnout
# -----------------------------------------------------------------------------
fps <-
	 list(
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2021%20June%20Democratic%20Primary.csv", # 2021
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2020%20June%20Democratic%20Primary.csv", # 2020
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2019%20June%20Democratic%20Primary.csv", # 2019
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2018%20June%20Democratic%20Primary%20.csv", # 2018
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2017%20June%20Democratic%20Primary.csv", # 2017
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2016%20June%20Democratic%20Primary.csv", # 2016
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2015%20June%20Democratic%20Primary.csv", # 2015
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2014%20June%20Democratic%20Primary.csv", # 2014
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2013%20June%20Democratic%20Primary.csv", # 2013
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2012%20June%20Democratic%20Primary.csv", # 2012
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2011%20August%20Democratic%20Primary.csv", # 2011
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2010%20March%20Democratic%20Primary.csv", # 2010
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2009%20June%20Democratic%20Primary.csv", # 2009
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2008%20June%20Democratic%20Primary.csv", # 2008
	 	"https://apps.elections.virginia.gov/SBE_CSV/ELECTIONS/ELECTIONTURNOUT/Turnout-2007%20June%20Democratic%20Primary.csv" # 2007
	 )

df_master <-
	tibble(
		election = as.character(),
		election_date = as.date(),
		locality = as.character(),
		precinct = as.character(),
		district = as.character(),
		district_type = as.character(),
		provisional_ballots = as.integer(),
		absentee_ballots = as.integer(),
		in_person_ballots = as.integer(),
		in_person_curbside_ballots = as.integer()
	)

df_list <- list()

for (i in 1:length(fps)) {
	fp <- fps[[i]]
	df <- 
		read_csv(file = fp, col_names = TRUE) %>%
		select(
			election, election_date, 
			locality, precinct, district, district_type,
			provisional_ballots, absentee_ballots, in_person_ballots, in_person_curbside_ballots,
			total_vote_turnout = TotalVoteTurnout)

	df_list[[i]] <- df
}

df <- bind_rows(df_list)
# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------