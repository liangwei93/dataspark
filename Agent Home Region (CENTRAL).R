library(httr)
library(dplyr)
library(jsonlite)

#parameters
datastreamx.key = "AUdFjYGZd4vwOTzxfPPqA17kzPVYaKFI"

#query API
query.body <- list(
  date = "2018-01-06",
  timeSeriesReference = "origin",
  location = list(locationType = "locationHierarchyLevel", levelType = "origin_subzone", id = "KLSZ05"),
  queryGranularity = list(type = "period", period = "PT1H"),
  filter = list( type = "selector", dimension = "agent_home_planningregion", value="CR"),
  dimensionFacets = list("agent_home_planningarea"),
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

write.csv(data.df, file = "ODMatrix AGENT HOME CENTRAL  jaychou.csv")


ggplot(data.df, aes(x = timestamp, y = event.longSum_total_records, color =event.agent_home_planningarea)) +
  geom_point() +
  labs(title="Plot by Agent Home Region",
       x ="Time", y = "Unique_agents") +
facet_wrap( ~ event.agent_home_planningarea)

ggsave("Agent Home Region (CENTRAL) JayChou Concert.png")

#plot(data.df$event.hyperUnique_unique_agents)
#title(main="People's Park by hour on 29th May 2017")

#p <- ggplot(TWOdaytimeseries, aes(x=TWOdaytimeseries$timestamp, y=TWOdaytimeseries$event.longSum_total_records)) +
#  geom_point() +
#  geom_density(alpha=.3) +
#  ggtitle("Timeseries ODMatrix 3031dec KLSZ05") +
#  xlab("Time") + ylab("Total Agents that started a trip from Tanjong Rhu")

#ggsave("ODMatrix 3031dec KLSZ05.png")
