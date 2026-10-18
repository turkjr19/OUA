
# ============================================================
# HockeyTech OUA Player Statistics Feed
# Download JSONP -> Parse JSON -> Tidyverse tibble
# ============================================================

library(tidyverse)
library(httr2)
library(jsonlite)

# ------------------------------------------------------------
# 1. URL
# ------------------------------------------------------------

url <- paste0(
  "https://lscluster.hockeytech.com/feed/index.php?",
  "feed=statviewfeed",
  "&view=players",
  "&season=193",
  "&team=all",
  "&position=skaters",
  "&rookies=0",
  "&statsType=expanded",
  "&rosterstatus=undefined",
  "&site_id=2",
  "&first=0",
  "&limit=1000",
  "&sort=points",
  "&order_direction=normal",
  "&league_id=5",
  "&lang=en",
  "&division=-1",
  "&conference=-1",
  "&key=0930e57c7a71fa87",
  "&client_code=oua",
  "&callback=angular.callbacks._4"
)

# ------------------------------------------------------------
# 2. Download feed
# ------------------------------------------------------------

response <- request(url) |>
  req_user_agent("Mozilla/5.0") |>
  req_perform()

raw_text <- resp_body_string(response)

# ------------------------------------------------------------
# 3. Remove JSONP wrapper and parse JSON
# ------------------------------------------------------------

json_text <- raw_text |>
  str_remove("^\\s*[A-Za-z0-9_.$]+\\s*\\(") |>
  str_remove("\\)\\s*;?\\s*$")

data <- fromJSON(
  json_text,
  simplifyVector = FALSE
)

# ------------------------------------------------------------
# 4. Inspect response structure
# ------------------------------------------------------------

cat("\nTop-level structure:\n")
print(names(data))

# ------------------------------------------------------------
# 5. Extract player records
# ------------------------------------------------------------

# Try the common HockeyTech response structure.
players_raw <- tryCatch(
  data[[1]]$sections[[1]]$data,
  error = function(e) NULL
)

# Stop with diagnostic information if the path differs.
if (is.null(players_raw) || length(players_raw) == 0) {
  cat("\nCould not find players at the expected location.\n")
  cat("Inspecting returned structure:\n")
  str(data, max.level = 5)
  
  stop(
    "Player data path differs from expected structure. ",
    "Use the structure printed above to adjust extraction."
  )
}

# ------------------------------------------------------------
# 6. Convert player records to a tibble
# ------------------------------------------------------------

players <- map_dfr(players_raw, function(player) {
  
  row <- player$row
  
  if (is.null(row)) {
    row <- player
  }
  
  as_tibble(row)
})

# ------------------------------------------------------------
# 7. Inspect results
# ------------------------------------------------------------

# cat("\nNumber of player records:", nrow(players), "\n")
# cat("\nColumn names:\n")
# print(names(players))
# 
# cat("\nFirst six records:\n")
# print(head(players))
# 
# glimpse(players)
# 
# # ------------------------------------------------------------
# # 8. Optional: sort by points, if that column exists
# # ------------------------------------------------------------
# 
# if ("points" %in% names(players)) {
#   
#   players <- players |>
#     mutate(points = as.numeric(points)) |>
#     arrange(desc(points))
#   
#   print(head(players, 20))
#   
# }

# ------------------------------------------------------------
# 8. ONT Ridgebacks players
# ------------------------------------------------------------
ont <- players %>% 
  filter(team_code == "ONT")
View(ont)

# ------------------------------------------------------------
# 9. Optional: export to CSV
# ------------------------------------------------------------

# write_csv(players, "oua_player_stats.csv")




oua_stats_url <- 'https://lscluster.hockeytech.com/feed/index.php?feed=statviewfeed&view=players&season=193&team=all&position=skaters&rookies=0&statsType=expanded&rosterstatus=undefined&site_id=2&first=0&limit=20&sort=points&order_direction=normal&league_id=5&lang=en&division=-1&conference=-1&key=0930e57c7a71fa87&client_code=oua&league_id=5&callback=angular.callbacks._4'


# Import game logs data from JSON
# use jsonlite::fromJSON to handle NULL values
df <- jsonlite::fromJSON(oua_stats_url, simplifyDataFrame = TRUE)
