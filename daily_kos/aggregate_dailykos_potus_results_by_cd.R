# -----------------------------------------------------------------------------
# Libraries
# -----------------------------------------------------------------------------
library(tidyverse)
library(googlesheets4)
# -----------------------------------------------------------------------------
# Aggregate Daily Kos presidential election results by congressional district.
# -----------------------------------------------------------------------------
# 2020 District Lines
# -----------------------------------------------------------------------------
# Results for 2008-2016 cycles.
df_08_16 <- 
	read_sheet(ss = "1whYBonfwlgTGnYl7U_IH31G0JNYQ9QBIjDfqkZHkW-0", skip = 1) %>%
	rename(	cd = 1, 
			dem16 = 4, rep16 = 5,
			dem12 = 6, rep12 = 7,
			dem08 = 8, rep08 = 9) %>%
	mutate(	potus_dem_twoway_2016 = dem16/(dem16+rep16),
			potus_dem_twoway_2012 = dem12/(dem12+rep12),
			potus_dem_twoway_2008 = dem08/(dem08+rep08)) %>%
	select(cd, starts_with("potus")) %>%
	pivot_longer(cols = starts_with("potus"), 
				names_to = "cycle", names_prefix = "potus_dem_twoway_",
				values_to = "dem_twoway")

# Results for the 2020 cycle.
df_20 <- 
	read_sheet(ss = "1XbUXnI9OyfAuhP5P3vWtMuGc5UJlrhXbzZo3AwMuHtk", skip = 1) %>%
	rename(	cd = 1, 
			dem20 = 4, rep20 = 5) %>%
	mutate(	potus_dem_twoway_2020 = dem20/(dem20+rep20)) %>%
	select(cd, potus_dem_twoway_2020) %>%
	pivot_longer(cols = c("potus_dem_twoway_2020"), 
				names_to = "cycle", names_prefix = "potus_dem_twoway_",
				values_to = "dem_twoway")

# Merge and save data.
df <- 
	bind_rows(df_08_16, df_20) %>% 
	mutate(cd = trimws(cd), district_lines = 2020) %>%
	arrange(cd, desc(cycle)) %>%
	select(cd, cycle, district_lines, dem_twoway)

write_csv(x = df, file = "dailykos_potus_results_by_cd_2020_lines.csv")
# Clear workspace.
rm(list = ls())
# -----------------------------------------------------------------------------
# 2018 District Lines
# -----------------------------------------------------------------------------
df <-
	read_sheet(ss = "1zLNAuRqPauss00HDz4XbTH2HqsCzMe0pR8QmD1K8jk8", skip = 1) %>%
	rename(	cd = 1, 
			dem16 = 4, rep16 = 5,
			dem12 = 6, rep12 = 7,
			dem08 = 8, rep08 = 9) %>%
	mutate(	potus_dem_twoway_2016 = dem16/(dem16+rep16),
			potus_dem_twoway_2012 = dem12/(dem12+rep12),
			potus_dem_twoway_2008 = dem08/(dem08+rep08)) %>%
	select(cd, starts_with("potus")) %>%
	pivot_longer(cols = starts_with("potus"), 
				names_to = "cycle", names_prefix = "potus_dem_twoway_",
				values_to = "dem_twoway") %>%
	mutate(cd = trimws(cd), district_lines = 2018) %>%
	arrange(cd, desc(cycle)) %>%
	select(cd, cycle, district_lines, dem_twoway)

write_csv(x = df, file = "dailykos_potus_results_by_cd_2018_lines.csv")
# -----------------------------------------------------------------------------
# 2016 District Lines
# -----------------------------------------------------------------------------
df <-
	read_sheet(ss = "1VfkHtzBTP5gf4jAu8tcVQgsBJ1IDvXEHjuMqYlOgYbA", skip = 1) %>%
	rename(	cd = 1, 
			dem16 = 4, rep16 = 5,
			dem12 = 6, rep12 = 7,
			dem08 = 8, rep08 = 9) %>%
	mutate(	potus_dem_twoway_2016 = dem16/(dem16+rep16),
			potus_dem_twoway_2012 = dem12/(dem12+rep12),
			potus_dem_twoway_2008 = dem08/(dem08+rep08)) %>%
	select(cd, starts_with("potus")) %>%
	pivot_longer(cols = starts_with("potus"), 
				names_to = "cycle", names_prefix = "potus_dem_twoway_",
				values_to = "dem_twoway") %>%
	mutate(cd = trimws(cd), district_lines = 2016) %>%
	arrange(cd, desc(cycle)) %>%
	select(cd, cycle, district_lines, dem_twoway)

write_csv(x = df, file = "dailykos_potus_results_by_cd_2016_lines.csv")
# -----------------------------------------------------------------------------
# 2012-2014 District Lines - The same lines were used for both cycles, but we
# want to duplicate the data for ease of use.
# -----------------------------------------------------------------------------
lines <- list(2012, 2014)

for(i in 1:length(lines)) {
	dl <- lines[[i]]

	df <-
		read_sheet(ss = "1xn6nCNM97oFDZ4M-HQgoUT3X4paOiSDsRMSuxbaOBdg", skip = 1) %>%
		rename(	cd = 1,
				dem12 = 4, rep12 = 5,
				dem08 = 6, rep08 = 7) %>%
		mutate(	potus_dem_twoway_2012 = dem12/(dem12+rep12),
				potus_dem_twoway_2008 = dem08/(dem08+rep08)) %>%
		select(cd, starts_with("potus")) %>%
		pivot_longer(cols = starts_with("potus"), 
					names_to = "cycle", names_prefix = "potus_dem_twoway_",
					values_to = "dem_twoway") %>%
		mutate(cd = trimws(cd), district_lines = dl) %>%
		arrange(cd, desc(cycle)) %>%
		select(cd, cycle, district_lines, dem_twoway)

	fn <- str_c("dailykos_potus_results_by_cd_", dl ,"_lines.csv")
	write_csv(x = df, file = fn)
}