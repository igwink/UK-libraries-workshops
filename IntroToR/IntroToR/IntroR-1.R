# Intro to R: Session 1 ---------------------------------------------------

# In this session, we'll begin with visualizing data in R to give you a sense
# of R's capabilities and the modular nature of writing code. 

# We'll then cover some of the different types of data that R handles.

# For a deeper dive into the concepts covered here, see Chapter 1 of R for 
# Data Science (2nd edition): https://r4ds.hadley.nz/


# Library Loading ----------------------------------------------------------

# An R script should always start by loading the libraries it will use:
library(ggplot2)
library(tidyverse)


# ggplot2 and the "Grammar of Graphics" ------------------------------------

# We'll build up to this finished plot step by step:
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, 
                 color = Species, shape = Species)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Iris Petal Length vs. Sepal Length",
    subtitle = "Measurements for Setosa, Versicolor, and Virginica Varieties",
    x = "Sepal Length (cm)", y = "Petal Length (cm)",
    color = "Species", shape = "Species"
  )

# First, let's get to know our dataset using glimpse():
glimpse(iris)

# Plot iris:
ggplot(iris)

# Plot iris. 
# Put the Sepal.Length column on the X-axis and the Petal.Length
# column on the Y-axis:
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length))


# Plot iris. 
# Put the Sepal.Length column on the X-axis and the Petal.Length
# column on the Y-axis.
# Display the data as points:
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) +
  geom_point()


# Plot iris. 
# Put the Sepal.Length column on the X-axis and the Petal.Length
# column on the Y-axis (color coding based on the values in species).
# Display the data as points:
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Species, 
                 shape = Species)) +
  geom_point()


# Plot iris. 
# Put the Sepal.Length column on the X-axis and the Petal.Length
# column on the Y-axis (color coding based on the values in species).
# Display the data as points.
# Display a trend line of the linear relationship between Sepal.Length and 
# Petal.Length (without the standard error bars):
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Species, 
                 shape = Species)) +
  geom_point() + 
  geom_smooth(method = "lm", se = FALSE)

# Plot iris. 
# Put the Sepal.Length column on the X-axis and the Petal.Length
# column on the Y-axis (color coding based on the values in species).
# Display the data as points.
# Display a trend line of the linear relationship between Sepal.Length and 
# Petal.Length (without the standard error bars).
# Add descriptive labels:
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Species, shape = Species)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Iris Petal Length vs. Sepal Length",
    subtitle = "Measurements for Setosa, Versicolor, and Virginica Varieties",
    x = "Sepal Length (cm)", y = "Petal Length (cm)",
    color = "Species", shape = "Species"
  )

# Exercise:
# Following the examples above, create a scatterplot using other variables in
# the iris dataset. Peek at the variables with glimpse(iris) first.



# Plotting Other Types of Variables ----------------------------------------

# In the plot above, the type of the chart was set by geom_point(), which made
# the plot a scatterplot. Geom functions determine the literal shape of our data. 

# Boxplots can display the distribution of a continuous variable and help
# identify outliers. They can also display a continuous variable broken down by
# a categorical one.

# Exercise:
# Use geom_boxplot() to display the distribution of a continuous variable.



# A bar chart can give us the distribution (count) of a categorical variable.
# (Unfortunately for this dataset, the result is boring.)

# Exercise:
# Use geom_bar() to display the distribution of a categorical variable.



# A histogram displays the distribution of a continuous variable by grouping
# values into bins of a fixed width.

# Exercise:
# Use geom_histogram() to display the distribution of a continuous variable.



# Saving Plots -------------------------------------------------------------

# ggsave() saves the most recently created plot with the name you specify.

# Exercise:
# Copy the code for your favorite plot above and paste it below, then run it.



# Then save it with ggsave() and a descriptive file name:
ggsave(filename = "iris_petallength_v_sepallength.png")


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
