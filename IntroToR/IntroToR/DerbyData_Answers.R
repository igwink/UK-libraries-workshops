library(tidyverse)
library(ggplot2)

# We will return to this script with each workshop in the series. Your challenge
# is to write code from scratch using the directions in the code comments.

# The dataset we will be using contains information on Kentucky Derby winners
# from 1875-2022 and comes from here: https://www.kaggle.com/datasets/danbraswell/kentucky-derby-winners-18752022?resource=download
derby <- read_csv("kentucky_derby_winners.csv")

# In addition to the workshop materials, you can gain more insight on the 
# material demonstrated here in R for Data Science (2nd edition):
# https://r4ds.hadley.nz/


# Session 1 Challenges: Data Visualization --------------------------------


# Take a peak at the data in the console:
glimpse(derby)

# Create a line graph with time on the Y-axis and year on the X-axis:
# HINT: Use geom_line():
ggplot(derby, aes(x = year, y = time_sec)) + 
  geom_line()

# Create a scatterplot of time vs. year, with track condition mapped to color:
ggplot(derby, aes(x = year, y = time_sec, color = track_condition)) + 
  geom_point() 

# Create a boxplot of finishing times, grouped by track condition:
# (We will discuss the meaning of these track conditions and apply it to the
# plot in the next session)
ggplot(derby, aes(y = time_sec, x = track_condition)) + 
  geom_boxplot()

# Create a bar chart showing the number of times each trainer has won the Derby:
# NOTE: The plot will look terrible. We'll discuss some ways to improve it next
# session.
ggplot(derby, aes(x = trainer)) +
  geom_bar()




# Session 2 Challenges: Data Manipulation with Dplyr ------------------------

# What distances have been run for the Kentucky Derby?:
derby |> 
  count(distance)

# Create a new column called speed using the time_sec and distance columns.
# Once you are satisfied that your code does what you want, update the code
# so that the speed variable is saved to the derby dataset:
derby <- derby |> 
  mutate(speed = distance / time_sec)

# Create a plot of speed vs. year. Compare it to the plot you created of 
# time vs. year in the last session:
ggplot(derby, aes(x = year, y = speed)) +
  geom_line()

# Sort the data from fastest to slowest horse, selecting the year, horse name,
# and speed:
derby |> 
  arrange(desc(speed)) |> 
  select(year, winner, speed)

# Use count() and arrange() to list the trainers that have won the most often:
derby |> 
  count(trainer) |> 
  arrange(desc(n))

# Building upon your pipeline above, create a table of only trainers that have
# won more than once and the number of times they've won:
derby |> 
  count(trainer) |> 
  arrange(desc(n)) |> 
  filter(n > 1)

# Determine if the same horse has ever won the Derby more than once:
derby |> 
  count(winner) |> 
  filter(n > 1)

# The track conditions in horseracing have a specific order to them, but when
# we loaded in our data, R treated them all as character data. 
# The line of code creates a vector with the track conditions ordered from 
# driest to wettest. Use this vector to refactor the track_condition into a new
# column called track_factor, updating derby with the new column:
condition_factor <- c("Fast", "Good", "Wet Fast (sealed)", "Sloppy", "Muddy",
                      "Slow", "Heavy")

derby <- derby |> 
  mutate(track_factor = fct(track_condition, condition_factor))

# Create a plot containing boxplots of speed grouped by track_factor:
# Hint: The plot will look better if you put track_factor on the y-axis:
ggplot(derby, aes(x = speed, y = track_factor)) + 
  geom_boxplot()

# For comparison, create a plot containing boxplots of speed grouped 
# by track_condition:
ggplot(derby, aes(x = speed, y = track_condition)) + 
  geom_boxplot()

# More on track conditions here: https://www.twinspires.com/edge/racing/an-introduction-to-track-conditions-and-all-the-related-lingo/

# Finally, save the transformed copy of your data to a new CSV with a new name:
write_csv(derby, "kentucky_derby_winners_v02.csv")



# Session 3 Challenges: Data Transformation -------------------------------

# We will be using the speed and track_factor columns, so be sure to load the
# new version of the data you saved last week. Since CSVs do no save factors,
# repeat your code from above to create the track_factor column:
derby <- read_csv("kentucky_derby_winners_v02.csv")

condition_factor <- c("Fast", "Good", "Wet Fast (sealed)", "Sloppy", "Muddy",
                      "Slow", "Heavy")

derby <- derby |> 
  mutate(track_factor = fct(track_condition, condition_factor))

# Use summarize() to find the average finishing time (time_sec) across all
# Derby winners, along with the number of winners in the dataset:
glimpse(derby)

derby |> 
  summarize(meantime = mean(time_sec), n = nrow())

# The triple_crown_winner column holds TRUE/FALSE values. Use summarize() and
# mean() to find the proportion of Derby winners who went on to win the
# Triple Crown:
# HINT: Taking the mean() of a TRUE/FALSE column works just like taking the
# mean of a column of 1s and 0s.
example <- c(TRUE, FALSE)
mean(example)

derby |> 
  summarize(triplecrown_prop = mean(triple_crown_winner))

# In the last session we used count(trainer) to count wins per trainer. 
# derby |> 
#   count(trainer) 
# has the same result as
# derby |> 
#   group_by(trainer) |>
#   summarize(n = n())
# Group by trainer and find both the number of wins and the average speed of 
# each trainer's, winning horses, sorted to show the trainers with the most wins:
derby |> 
  group_by(trainer) |> 
  summarize(wins = n(), meanspeed = mean(speed)) |> 
  arrange(desc(wins))

# Group by track_factor and find the average speed and the number of races
# for each condition, sorted from fastest to slowest average speed:
derby |> 
  group_by(track_factor) |> 
  summarize(meanspeed = mean(speed), n = n()) |> 
  arrange(desc(meanspeed))

# Repeat your pipeline above, but sort by track_factor instead of average speed:
derby |> 
  group_by(track_factor) |> 
  summarize(meanspeed = mean(speed), n = n()) |> 
  arrange(track_factor)

# Take the summary you just made and pipe it into ggplot() to create a bar
# chart of average speed by track condition:
# HINT: Use geom_col(), which draws bars at heights you supply, rather than
# geom_bar(), which counts rows for you.
derby |> 
  group_by(track_factor) |> 
  summarize(meanspeed = mean(speed), n = n()) |> 
  arrange(track_factor) |> 
  ggplot(aes(x = track_factor, y = meanspeed)) +
  geom_col()

# Group by distance and find the average time_sec, the average speed, and the
# number of races at each distance:
# NOTE: The Derby has been run at two distances. Why is it more meaningful to
# compare speed than time when the distances differ?
derby |> 
  group_by(distance) |> 
  summarize(meantime = mean(time_sec), meanspeed = mean(speed), n = n())

# All of the 1.5-mile races were run before 1896. Filter the data to only the
# modern 1.25-mile races, then group by track_factor and find the average
# speed and number of races, sorted from fastest to slowest:
# How does dropping the 1.5-mile races change the ranking you found earlier?
derby |> 
  filter(distance == 1.25) |> 
  group_by(track_factor) |> 
  summarize(meanspeed = mean(speed), n = n()) |> 
  arrange(desc(meanspeed))

# Group by track_factor and find the average finishing time (time_sec) for
# each, sorted from slowest to fastest. It looks like the wettest tracks 
# (Heavy and Muddy) come out with the slowest average times.
# Before concluding that a wet track slows a horse down, what might you want to
# check first?
derby |> 
  group_by(track_factor) |> 
  summarize(meantime = mean(time_sec)) |> 
  arrange(desc(meantime))

# Is there a plot that could help you answe that question?
ggplot(derby, aes(x = year, y = time_sec, color = track_factor)) +
  geom_point()

