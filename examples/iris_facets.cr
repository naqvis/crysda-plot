# Iris Faceted Plots - Small Multiples
#
# This example demonstrates:
# - Faceted/small multiples visualization
# - One subplot per group (species)
# - Automatic grid layout
#
# Creates separate scatter plots for each iris species side by side.

require "../src/crysda-plot"

# Load the Iris dataset
iris = Crysda.read_csv("examples/data/iris.txt", separator: '\t')

puts "Iris Dataset - Faceted by Species"
puts "=================================="
puts ""

# Create faceted scatter plots - one per species
fig = iris
  .group_by("Species")
  .plot_facet_scatter("Petal.Length", "Petal.Width")

fig.title("Petal Dimensions by Species")
fig.size(1200, 400) # Wider for 3 side-by-side plots

fig.save("examples/iris_facets.png")
puts "Saved: examples/iris_facets.png"
