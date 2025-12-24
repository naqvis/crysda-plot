# Iris Species Analysis - Grouped Scatter Plot
#
# This example demonstrates:
# - Loading real CSV data (classic Iris dataset)
# - Data transformation and filtering
# - Grouped scatter plots with automatic series labeling
# - Cryplot styling: custom ranges, title, legend positioning
#
# The Iris dataset contains measurements of 150 iris flowers from 3 species:
# setosa, versicolor, and virginica. We visualize how petal dimensions
# can distinguish between species.

require "../src/crysda-plot"

# Load the classic Iris dataset
iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

puts "Iris Dataset Overview:"
puts "======================"
iris.schema
puts ""

# Show species distribution
puts "Species counts:"
iris.count("Species").print
puts ""

# Create a grouped scatter plot: Petal Length vs Petal Width by Species
# This is a classic visualization showing how species cluster differently
plot = iris
  .group_by("Species")
  .plot_scatter("Petal.Length", "Petal.Width")

# Apply Cryplot styling for publication-quality output
plot.title("Iris Species Classification by Petal Dimensions")
plot.xrange(0.0, 7.5)
plot.yrange(0.0, 3.0)
plot.legend.at_top_left
plot.grid.show

# Save the plot
plot.save("examples/iris_species_scatter.png")
puts "Saved: examples/iris_species_scatter.png"

# Also display interactively (comment out if running headless)
# plot.show
