# Intro to R: Session 2 ---------------------------------------------------

# In this session, we'll begin by reviewing some of the key R concepts we
# introduced in the last session. 

# We'll then cover dplyr, a tidyverse package for transforming data.

# The data we'll be working with today comes from a 2023 survey of more than
# 11,000 respondents in 22 states on whether or not they consider themselves
# to be Midwesterners. The version we'll work with has been pre-cleaned, and
# fake data has been generated for income and household size. (All other 
# columns are genuine.) You can download the raw data here:
# https://nebraskapressjournals.unl.edu/middle-west-review-midwestern-survey/

# For a deeper dive into the concepts covered here, see Chapter 3 of R for 
# Data Science (2nd edition): https://r4ds.hadley.nz/

# Library Loading ----------------------------------------------------------

library(tidyverse)
library(ggplot2)


# Key R Concepts -----------------------------------------------------------

# Save a value to an object using <-
# We can then use that object using its assigned name in future code:
x <- 1
x + 1

# A vector is a list of other objects, created using c():
squares <- c(1, 4, 9, 16)

# It is generally good practice to make all objects in a vector the same type.
# If they are, you can perform operations on all objects in the vector:
squares - 2

# Text (or character) data in R should always be entered in quotes:
cities <- c("Lexington", "Louisville", "Paducah")

# Logical operators produce a special TRUE or FALSE value:
3 > 2
100 == 99 + 1
"Lexington" %in% cities


# Functions are the verbs of code and operate on objects (the nouns).
# The objects inside the parentheses of a function are its arguments.
# Some arguments are optional.
# For example, the function seq(x, y) will produce a vector containing numbers
# between x and y (inclusive). But it can also take a third argument indicating
# the step between numbers:
seq(1, 10)
seq(1, 10, 2)

# If we want to learn more about a function, we can type ? followed by the 
# function name and run it to view its documentation:
?round

# Looking at the documentation for round(), how would we round a number to the
# tenths place instead of to the ones place?
round(6.333)

# Factors allow us to set the order in which R sorts objects.

# Objects like integers have an inherent order, and a vector can be reordered
# using sort():
some_nums <- c(3, 4, 2, 1)
sort(some_nums)

# For character values, R defaults to sorting in alphabetical order, which
# doesn't always make sense. For example, we would rarely want to sort months
# in alphabetical order:
some_months <- c("Apr", "Mar", "Feb", "Jan", "Dec", "Nov", "May", "Oct", "Jun",
                 "Sep", "Jul", "Aug")
sort(some_months)

# We can first create a vector containing a series of levels in order, then use
# these levels to convert a list of character values to a factor. The factor
# will sort based on the order of the levels we specified:
month_levels <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug",
                  "Sep", "Oct", "Nov", "Dec")
some_months <- fct(some_months, month_levels)
sort(some_months)


# Data Transformation with Dplyr -------------------------------------------


# The Basics of Dplyr and Pipes --------------------------------------------

midwest <- read_csv("midwest-data.csv")


# Tools for viewing a dataset once we've loaded it in:
# glimpse() will display the data in the console:
glimpse(midwest)

# View() will display the data in a new window:
View(midwest)

# dplyr is a package for manipulating and transforming tabular data.
# It can be loaded in on its own with library(dplyr) but
# is already included in the tidyverse package.

# Most dplyr functions follow the same structure: 
# The function name is a verb
# The function arguments include a data frame and are typically followed by the 
#  columns to operate on
# The output is another data frame

# For example, the select() function returns only the columns we specify:
select(midwest, statecurrent, statebirth)

# The filter() function returns only rows that meet a certain condition:
filter(midwest, statecurrent == statebirth)

# In practice, we typically execute functions on a data frame using a special
# syntax known as pipes: |>
# Pipes take the output of one line of code and pass it to the next.
# Whenever you see a pipe symbol, you can translate it to mean "and then":
midwest |> 
  filter(statecurrent == statebirth) |> 
  select(statecurrent, statebirth)

# This code has the same output as the code above, but it's much harder to 
# understand what's going on:
select(
  filter(midwest, statecurrent == statebirth),
  statecurrent, statebirth)

# Exercise:
# Reverse the order of the functions above, using select() first and then
# filter(). Do you expect to get the same result?



# Dplyr Functions That Operate on Rows -------------------------------------

# filter() keeps only rows where a certain condition is TRUE.

# Notice in the output that the dimensions of the tibble change; the number of
# columns stays the same, but the number of rows changes:
midwest |> 
  filter(statecurrent == "KY")

# We can set multiple conditions at once:
midwest |> 
  filter(statecurrent == "KY", inmidwest == 1)

# Exercise:
# Filter the data frame to all rows for respondents living in Kentucky who are
# in the 30-39 age bracket.



# count() gives all unique values in a column and the number of times they occur:
midwest |> 
  count(gender)

# Exercise:
# Create a table with counts of all the values of ideology for respondents who
# did not vote.



# arrange() sorts the rows by values in a specified column:
midwest |> 
  arrange(statecurrent)

# By default, arrange() sorts by smallest to largest (for numbers) or from A-Z
# (for characters). We can reverse the order by using desc() inside arrange():
midwest |> 
  arrange(desc(statecurrent))

# How would we create a table with the count of respondents' current states,
# listed in descending order?
midwest |> 
  count(statecurrent) |> 
  arrange(desc(n))


# Dplyr Functions That Operate on Columns ----------------------------------

# select() is a handy function for shrinking a dataset to only contain the
# selected columns:
midwest |> 
  select(income, statebirth)

# mutate() creates a new column using an existing column.
# We will use mutate to round income to the tens of thousands place:
midwest |> 
  mutate(income_bracket = round(income, digits = -4))

# mutate() can even use two columns together. We use it here to create a new
# column for income per household member:
midwest |> 
  mutate(income_per_person = income / householdsize)

# So far, we have only displayed changes to our data. If we want to save a
# change, we need to save the new data frame we produce to a variable:
midwest <- midwest |> 
  mutate(income_per_person = income / householdsize)

# We can also use mutate() to change a column to a factor.
# Currently, R reads the education column as simple text. Although there are
# discrete categories used, R does not order them, as shown in this plot:
ggplot(midwest, aes(y = education)) +
  geom_bar()

# But using mutate(), we can change education to an ordered factor and then
# plot the data again:
ed_levels <- c("High School or Less", "Vocational/Technical School",
               "Associate's Degree/Some College", "College Degree",
               "Postgraduate or Higher")

midwest <- midwest |> 
  mutate(education = fct(education, ed_levels))

# Creating the same plot again, the education labels are now in order:
ggplot(midwest, aes(y = education)) +
  geom_bar()

# Exercise:
# Use mutate() and the age_levels below to change the age column to a factor,
# then re-create the bar plot to confirm the new order.
age_levels <- c("18-24", "25-29", "30-39", "40-49", "50-59", "60-69", 
                "70 or more years")



# It looks like some values of education are NA (not applicable). is.na() checks
# whether a value is NA and returns TRUE or FALSE:
is.na(3)
is.na(NA)

# Exercise:
# Use filter() and is.na() to identify the rows where education is missing.



# Saving Data to a CSV -----------------------------------------------------

# We added an additional column to our data (income_per_person) and may wish to
# save the new data frame. The following code will save it to a CSV, which can
# then be loaded back into R or downloaded and used elsewhere (such as Excel):
write_csv(midwest, "midwest-data_v02.csv")

# Two important notes:
# 1) Avoid naming the new file for your transformed data with the same name as
#    the original. R will overwrite your original file with no warning and you
#    may lose it forever.
# 2) A CSV file cannot retain information about factors. If we load the new file
#    we saved back into R, the age and education columns will once again be
#    characters instead of factors.
