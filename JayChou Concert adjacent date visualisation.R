library(httr)
library(dplyr)
library(jsonlite)

#parameters
datastreamx.key = "AUdFjYGZd4vwOTzxfPPqA17kzPVYaKFI"

#query API
query.body <- list(
  date = "2018-01-05",
  timeSeriesReference = "origin",
  location = list(locationType = "locationHierarchyLevel", levelType = "origin_subzone", id = "KLSZ05"),
  queryGranularity = list(type = "period", period = "PT1H"),
  aggregations = list(list(metric = "unique_agents", type = "hyperUnique"), list(metric = "total_records", type = "longSum"))
  )

  # token variable contains a valid access token; see Getting Started.
  query.response <- POST("http://api.datastreamx.com/1925/605/v1/odmatrix/v3/query",
                         add_headers('DataStreamX-Data-Key' = datastreamx.key),
                         encode = "json",
                         body = query.body,
                         verbose())

  stop_for_status(query.response)
  cat(content(query.response, as = "text"), "\n")

  #convert query response to JSON

  data <- fromJSON(rawToChar(query.response$content))
  data.df <- do.call(what = "cbind", args = lapply(data, as.data.frame))
  names(data.df)[1] = names(data[1])

  #write csv to working directory

  write.csv(data.df, file = "ODMatrix-JayChou-05012018.csv")
