# Iris Measurements Trend - Multi-Series Line Plot
#
# This example demonstrates:
# - Line plot with multiple Y series
# - Comparing trends across measurements
# - Data aggregation by group
#
# Shows average measurements for each iris species as a line chart,
# comparing how different measurements vary across species.

require "../src/crysda-plot"

# Load the Iris dataset
iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

# Aggregate measurements by species
species_avg = iris
  .group_by("Species")
  .summarize(
    "Sepal.Length".with { |df| df["Sepal.Length"].mean(true) },
    "Sepal.Width".with { |df| df["Sepal.Width"].mean(true) },
    "Petal.Length".with { |df| df["Petal.Length"].mean(true) },
    "Petal.Width".with { |df| df["Petal.Width"].mean(true) }
  )
  .sort_by("Petal.Length") # Order by increasing petal length

puts "Average measurements by species:"
species_avg.print
puts ""

# Add a numeric index for x-axis (1, 2, 3 for the three species)
indexed = species_avg.add_row_number("index")

# Create multi-series line plot comparing all four measurements
plot = indexed.plot_line("index", "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")

plot.title("Iris Measurements by Species")
plot.xlabel("Species (ordered by petal length)")
plot.ylabel("Measurement (cm)")
plot.xrange(0.5, 3.5)
plot.yrange(0.0, 8.0)
plot.legend.at_top_left
plot.grid.show

plot.save("examples/iris_measurements_line.png")
puts "Saved: examples/iris_measurements_line.png"
