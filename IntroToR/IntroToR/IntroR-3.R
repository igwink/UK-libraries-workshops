# Intro to R: Session 3 ---------------------------------------------------

# In this session, we'll get further into data transformation with dplyr,
# seeing how we can create new summary statistics for subsets of our
# data using group_by() and summarize(). 

# The data we'll be working with today comes from a 2023 survey of more than
# 11,000 respondents in 22 states on whether or not they consider themselves
# to be Midwesterners. The version we'll work with has been pre-cleaned, and
# fake data has been generated for income and household size. (All other 
# columns are genuine.) You can download the raw data here:
# https://nebraskapressjournals.unl.edu/middle-west-review-midwestern-survey/

# For a deeper dive into the concepts covered here, see Chapters 3 and 4 of R 
# for Data Science (2nd edition): https://r4ds.hadley.nz/

# Library Loading and Data Preparation -------------------------------------

library(tidyverse)
library(ggplot2)

midwest <- read_csv("midwest-data.csv")

# In the last session, we converted the education column from plain text into
# an ordered factor. We do the same here so our tables and plots stay in a
# sensible order. (Remember: a factor lets us set the order R uses when it
# sorts a column, instead of defaulting to alphabetical.)
ed_levels <- c("High School or Less", "Vocational/Technical School",
               "Associate's Degree/Some College", "College Degree",
               "Postgraduate or Higher")

midwest <- midwest |> 
  mutate(education = fct(education, ed_levels))

# Now we do the same for the age column:
age_levels <- c("18-24", "25-29", "30-39", "40-49", "50-59", "60-69", 
                "70 or more years")

midwest <- midwest |> 
  mutate(age = fct(age, age_levels))


# Data Transformation with Dplyr -------------------------------------------

# Thus far, we've used:
# select() to limit our dataset to certain columns,
# arrange() to sort rows,
# count() to create a table of the number of occurrences of a value in a column,
# filter() to limit our dataset to rows that meet a certain condition, and
# mutate() to create new columns from existing ones.

# While these functions are useful for rearranging or describing our data, they
# aren't as helpful for exploring trends.

# By performing additional data transformation, we'll be able to answer the
# following questions: 
# 1) What states have the largest percentage of respondents who 
#    identify as Midwesterners?
# 2) What states have the highest proportion of respondents who still live in
#    the state where they were born?

# To answer questions like these, we need two new tools: summarize() and
# group_by()


# Summarizing Data with summarize() ----------------------------------------

# summarize() collapses an entire data frame down into a single summary row.
# Inside summarize(), we name a new column and tell R how to calculate it.

# For example, here we calculate the average income across ALL respondents.
# The 11,095-row data frame becomes a single number in a one-row table:
midwest |> 
  summarize(avg_income = mean(income))

# We can calculate a summary for multiple variables at once by separating them 
# with commas. The function n() is special: it counts the number of rows.
midwest |> 
  summarize(avg_income = mean(income), 
            avg_household = mean(householdsize),
            n = n())

# A KEY TRICK: two of our columns, inmidwest and midwesterner, only contain
# 0s and 1s (0 = "no", 1 = "yes"). When you take the mean() of a column of
# 0s and 1s, you get the PROPORTION of 1s.
# For example, if a column is c(1, 1, 0, 1), its mean is 0.75, meaning 75% of
# the values are 1.

# So the mean of the inmidwest column tells us the proportion of all
# respondents who say they live in the Midwest:
midwest |> 
  summarize(inmidwest_prop = mean(inmidwest))

# Exercise:
# Write a summarize() that calculates the proportion of all respondents who
# identify as Midwesterners (use the midwesterner column)



# Grouping Data with group_by() --------------------------------------------

# On its own, a single summary isn't very interesting.
# Usually we want to compare GROUPS. For example, what is the average income
# in each state?

# group_by() splits the data into groups behind the scenes. On its own, it
# doesn't appear to change much, but it changes what summarize() does next.
# Instead of one summary for the whole dataset, summarize() returns one summary
# row PER GROUP.

# Here we group by state, then find the proportion identifying as Midwesterners
# in each state. We get one row per state instead of one row overall:
midwest |> 
  group_by(statecurrent) |> 
  summarize(midwesterner_prop = mean(midwesterner))

# Just like before, we can calculate several summaries at once. Including n()
# is a good habit, since it tells us how many respondents are in each group:
midwest |> 
  group_by(statecurrent) |> 
  summarize(inmidwest_prop = mean(inmidwest), 
            midwesterner_prop = mean(midwesterner), 
            n = n())

# The data frame above doesn't appear to be sorted in any order.
# To answer Question 1 (which states have the most Midwesterners?), we add
# arrange(desc()) to sort the summary table from highest to lowest:
midwest |> 
  group_by(statecurrent) |> 
  summarize(inmidwest_prop = mean(inmidwest), 
            midwesterner_prop = mean(midwesterner), 
            n = n()) |> 
  arrange(desc(midwesterner_prop))

# Exercise:
# Adapt the code above to group by age instead of statecurrent. Which age
# group has the highest proportion identifying as Midwesterners?



# Exploring Questions with Grouped Summaries -------------------------------

# Now that we can group and summarize, we can investigate more nuanced
# questions just by changing what we group by or how we summarize.

# Question 2: What states have the highest proportion of respondents who still
# live in the state where they were born?
# The expression statecurrent == statebirth is TRUE when the two match and
# FALSE when they don't. Taking the mean() of TRUE/FALSE values works just like
# taking the mean of 1s and 0s: it gives us the proportion that are TRUE.

# Here's an example of getting the proportion of values in two columns that match:
example1 <- c("KY", "FL", "OH")
example2 <- c("KY", "IL", "IA")

example1 == example2
mean(example1 == example2)

# Now let's try it on the actual data:
midwest |> 
  group_by(statecurrent) |> 
  summarize(stayed_prop = mean(statecurrent == statebirth), 
            n = n()) |> 
  arrange(desc(stayed_prop))

# By running the code above, stayed_prop has a large number of NA values. That's
# because trying to take the mean of a column with at least one NA value
# will result in NA. To remove the missing value, we use na.rm = TRUE:
example1 <- c("KY", "FL", "OH", NA)
example2 <- c("KY", "IL", "IA", "HI")

example1 == example2
mean(example1 == example2, na.rm = TRUE)

# Add na.rm = TRUE to the right place in the code above to calculate the 
# proportion of people in each state who were born there.


# Question 3: Where is the gap largest between people who say they LIVE in the 
# Midwest and people who IDENTIFY as a Midwesterner? We can build a new column 
# with mutate() after summarizing:

# To do so, we use abs() to get the absolute value of the difference between the
# two proportions:
abs(2 - 3)

midwest |> 
  group_by(statecurrent) |> 
  summarize(inmidwest_prop = mean(inmidwest), 
            midwesterner_prop = mean(midwesterner), 
            n = n()) |> 
  mutate(gap = abs(inmidwest_prop - midwesterner_prop)) |> 
  arrange(desc(gap))

# Question 4: What state "makes" the most Midwesterners? In other words, among 
# respondents who do NOT live in the state where they were born, what percentage 
# identify as a Midwesterner? Here we filter() first to create a subset of our
# data, then group and summarize:
midwest_newstate <- midwest |> 
  filter(statecurrent != statebirth)

midwest_newstate |> 
  group_by(statecurrent) |> 
  summarize(inmidwest_prop = mean(inmidwest), 
            midwesterner_prop = mean(midwesterner), 
            n = n()) |> 
  arrange(desc(midwesterner_prop))

# We aren't limited to grouping by state. What happens if we group by race?
midwest |> 
  group_by(race) |> 
  summarize(inmidwest_prop = mean(inmidwest), 
            midwesterner_prop = mean(midwesterner), 
            n = n()) |> 
  arrange(desc(midwesterner_prop))

# Suppose someone looked at the table above and concluded "Identifying as Asian
# makes a person more likely to identify as a Midwesterner." Would that be an
# accurate statement?

# Be skeptical of associations like this! A grouped summary shows us a pattern,
# but it does not explain WHY the pattern exists. If respondents of a given race
# happen to be concentrated in states with strong Midwestern identity, that
# alone could drive the result. The table below shows the proportion of each
# state's respondents who are Asian, hinting at this kind of explanation:
midwest |> 
  group_by(statecurrent) |> 
  summarize(prop_asian = mean(race == "Asian")) |> 
  arrange(desc(prop_asian))

# Exercise:
# Group by partyregaff (party affiliation) and summarize the proportion who
# identify as Midwesterners, along with the number of respondents in each group.
# Sort from highest to lowest. Before you read the result, jot down what you'd
# want to check before treating any difference as meaningful.



# Reshaping Data with pivot_wider() ----------------------------------------

# So far, every grouped summary has produced a "long" table: one row per group.
# When we group by TWO variables, we get one row per combination. Here we get
# one row for every state-and-education-level pair (we filter out the handful of
# rows where education is missing first using !is.na(education)):
midwest |> 
  filter(!is.na(education)) |> 
  group_by(statecurrent, education) |> 
  summarize(midwesterner_prop = mean(midwesterner))


# That long table is accurate and may be helpful for creating certain
# visualizations, but it's hard to scan. A crosstab (also called a
# cross-tabulation) is often easier to read: one variable down the side, the
# other across the top, and a value in each cell.

# pivot_wider() reshapes a long table into this wide format. We tell it:
#   names_from  = the column whose values become the new column headers
#   values_from = the column that fills in the cells
# Here, each education level becomes its own column, and each cell holds the
# proportion of that state's respondents (at that education level) who identify
# as a Midwesterner:
midwest_statecurrent_ed <- midwest |> 
  filter(!is.na(education)) |> 
  group_by(statecurrent, education) |> 
  summarize(midwesterner_prop = mean(midwesterner)) |> 
  pivot_wider(names_from = education, values_from = midwesterner_prop)

# Since this table is larger, let's view it in a separate window:
View(midwest_statecurrent_ed)

# Reading the table: each row is a state, each column is an education level, and
# the number where a row and column meet is the proportion of those respondents
# who identify as Midwesterners. Reading across a row shows whether identity
# changes with education within a single state.

# Exercise:
# Create a similar crosstab, but use a different variable across the top. For
# example, swap education for age (you can skip the is.na() filter, since age
# has no missing values here). What patterns, if any, do you notice?



# Advanced Examples (Demonstration Only) -----------------------------------

# The two visualizations below go beyond what we cover in detail today. Feel
# free to run them and explore the code on your own after the workshop.

# Create a heatmap of Midwestern identification by race and state:
midwest |> 
  group_by(statecurrent, race) |> 
  summarize(inmidwest_prop = mean(inmidwest), midwesterner_prop = mean(midwesterner), 
            n = n()) |> 
  ungroup() |> 
  mutate(statecurrent = fct_reorder(statecurrent, midwesterner_prop)) |>
  mutate(race = fct_reorder(race, n, sum, .desc = TRUE)) |> 
  ggplot(aes(y = statecurrent, x = race)) +
  geom_tile(aes(fill = midwesterner_prop))

# Create a chloropleth of the percentage of respondents in each state 
# identifying as a Midwesterner:
install.packages("plotly")
library(plotly)

midwest_prop <- midwest |> 
  group_by(statecurrent) |> 
  summarize(inmidwest_prop = mean(inmidwest), midwesterner_prop = mean(midwesterner), 
            n = n()) |> 
  mutate(gap = abs(inmidwest_prop - midwesterner_prop)) |> 
  arrange(desc(gap))

# Adapted from this example: https://plotly.com/r/choropleth-maps/
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

fig <- plot_geo(midwest_prop, locationmode = "USA-states") |> 
  add_trace(z = ~inmidwest_prop, locations = ~statecurrent, type = "chloropleth") |> 
  layout(geo = g) |> 
  colorbar(title = "Percentage of Respondents \nSaying They Are in the \nMidwest")
fig

# The following code can save the chloropleth map as a PNG, but it may push
# the memory limit of RStudio online:
# reticulate::py_install('plotly')
# reticulate::py_install('kaleido')
# save_image(fig, file = "midwest_id.png", width = 1200, height = 800)
