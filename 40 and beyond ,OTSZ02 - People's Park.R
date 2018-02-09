library(httr)
library(dplyr)
library(jsonlite)

#parameters
datastreamx.key = "AUdFjYGZd4vwOTzxfPPqA17kzPVYaKFI"

#query API
query.body <- list(
  date = "2017-12-02",
  location = list(locationType = "locationHierarchyLevel", 
                  levelType = "staypoint_subzone", 
                  id = "OTSZ02"
                  ),
  queryGranularity = list(type = "period", 
                          period = "PT2H30M"),
  filter = list( type = "bound", dimension = "agent_year_of_birth", lower = "1930", upper ="1978"),
  dimensionFacets = list("agent_gender"),
  aggregations = list(list(metric = "unique_agents", type = "hyperUnique"))
)

# token variable contains a valid access token; see Getting Started.
query.response <- POST("http://api.datastreamx.com/1925/605/v1/staypoint/v2/query",
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

write.csv(data.df, file = "Staypoint-API_genderfacet-output.csv")

ggplot(data.df, aes(x = timestamp, y = event.hyperUnique_unique_agents, shape = event.agent_gender)) +
  geom_point() +
  labs(title="40 and beyond ,OTSZ02 - People's Park",
       x ="Time", y = "Unique_agents") 
  #facet_wrap( ~ data_5099_301217_dhoby$event__agent_gender)

#plot(data.df$event.hyperUnique_unique_agents)
#title(main="People's Park by hour on 29th May 2017")

