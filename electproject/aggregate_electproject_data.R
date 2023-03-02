# -----------------------------------------------------------------------------
# Libraries
# -----------------------------------------------------------------------------
library(tidyverse)
library(googlesheets4)
library(bigrquery)
# -----------------------------------------------------------------------------
# Aggregate Michael McDonald's turnout estimates for the 2000-2020 general
# elections.
# -----------------------------------------------------------------------------
df <-
	tibble(
		cycle = seq(from = 2000, to = 2020, by = 2),
		sheet = 
			c(
				"1pM7qXCdHwGFUwiMOxYdepm9Yl5ygr06lLcZaRZsjMtI", #2000g
				"1KzJN_mBBBF0z9jhPHZWxsmWVIovfN0uqIoMw3Q8Wznw", #2002g
				"1eNAo1DjqtGqhc_vEHdPpIFd1TeoTxiCpV9ueA7eREMs", #2004g
				"10-W904bA-dcVrHXgUUh2G0WVfJoW7BObN26grBIWSq0", #2006g
				"1deCSqgLqrzFgpUa_S8Gk-8mKrPq47pkx1eqKwZGtSqA", #2008g
				"1xH_qRlVmK5JMZWxOJS_PPp0_6w6vMcTaZcjfSfIXJ-4", #2010g
				"1EYjW8l4y-5xPbkTFjdjdpnxOCgVvB8rM_oqjtJhtQKY", #2012g
				"1s2KkvXl4kY6UvC47bksgsJ5kZPoFtdL4L5Roqb0bTJI", #2014g
				"1VAcF0eJ06y_8T4o2gvIL4YcyQy8pxb1zYkgXF76Uu1s", #2016g
				"1tal3fAaKnEj_7Yy_7ftrNg4dJy4UxGk3oKSd3uPb13Y", #2018g
				"1h_2pR1pq8s_I5buZ5agXS9q1vLziECztN2uWeR6Czo0") #2020g
			)

# Download files, standardize column names, only keep columns of interest,
# and save files locally.
df_list <- list()

for(i in 1:nrow(df)) {
	c <- df$cycle[i]
	s <- df$sheet[i]

	# McDonald maintained a consistent file format for the 2000-2014 cycles.
	if(c < 2016) {
		d <- 
			read_sheet(ss = s, skip = 1) %>%
			rename(	
				state_name = 1,
				ballots_counted = 5,
				votes_highest_office = 6,
				vep = 7,
				vap = 8
			)
	# McDonald introduced a new spreadsheet format in 2016.
	} else if (c == 2016) {
		d <- 
			read_sheet(ss = s, skip = 1) %>%
			rename(	
				state_name = 1,
				ballots_counted = 7,
				votes_highest_office = 8,
				vep = 9,
				vap = 10
			)
	# McDonald introduced a new spreadsheet format in 2018.
	} else if (c == 2018) {
		d <- 
			read_sheet(ss = s, skip = 1) %>%
			rename(	
				state_name = 1,
				ballots_counted = 6,
				votes_highest_office = 7,
				vep = 8,
				vap = 9
			)
	# McDonald introduced a new spreadsheet format in 2020.
	} else {
		d <-
			read_sheet(ss = s, skip = 1) %>%
			rename(	
				state_name = 1,
				ballots_counted = 4,
				votes_highest_office = 5,
				vep = 8,
				vap = 9
			)
	}

	# Add cycle to data frame, select columns we want to keep, and drop
	# extraneous rows.
	d <- 
		d %>%
		mutate(cycle = c) %>%
		select(cycle, state_name, vap, vep, ballots_counted, votes_highest_office) %>%
		# We don't need the national roll-up row. If needed, we can reproduce
		# it by rolling-up the state-level data.
		filter(str_detect(state_name, "United") == FALSE) %>%
		filter(is.na(vap) == FALSE) %>%
		# Want to store the numbers as integers, but first need to round them,
		# otherwise they'd be truncated instead of rounded.
		mutate_if(is.numeric, round) %>%
		mutate_if(is.numeric, as.integer) %>%
		# Remove asterisk from states that had a note.
		mutate(state_name = trimws(state_name) %>% str_replace_all("\\*", ""))

	# Save file.
	fn <- str_c("electproject_", c, "_general.csv")
	write_csv(x = d, file = fn)

	# Store data in df_list.
	df_list[[i]] <- d

	# Introduce a pause to avoid API rate limit errors.
	Sys.sleep(5)
	
	rm(d)
}

# Create master data set by stitching together all of the cycle-specific
# datsets and save as one CSV.
df <- 
	bind_rows(df_list)

write_csv(x = df, file = "electproject_2000-2020_general.csv")

# -----------------------------------------------------------------------------
# Store results in Google BigQuery
# -----------------------------------------------------------------------------
bq_dataset_create(x = "election-data.electproject", region = "US")