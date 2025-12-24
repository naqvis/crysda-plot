# Plotting extensions for Crysda DataFrames using Cryplot
module Crysda
  # Global plot configuration
  module PlotConfig
    # Default figure dimensions (in points, 72 points = 1 inch)
    class_property default_width : Int32 = 800
    class_property default_height : Int32 = 600
  end

  # Helper module for extracting plot data from DataFrames
  module PlotDataExtractor
    # Convert value to Float64 if possible
    def self.to_float64(val) : Float64?
      case val
      when Float64 then val
      when Int32   then val.to_f64
      when Int64   then val.to_f64
      when Number  then val.to_f64
      else              nil
      end
    end

    # Extract numeric column data as Array(Float64), skipping nil values
    # Returns tuple of {x_values, y_values} with matching indices (nils removed from both)
    def self.extract_numeric_pair(df : DataFrame, x_col : String, y_col : String) : {Array(Float64), Array(Float64)}
      x_data = df[x_col]
      y_data = df[y_col]

      x_vals = [] of Float64
      y_vals = [] of Float64

      df.num_row.times do |i|
        x_val = to_float64(x_data[i])
        y_val = to_float64(y_data[i])

        if x_val && y_val
          x_vals << x_val
          y_vals << y_val
        end
      end

      {x_vals, y_vals}
    end

    # Extract single numeric column as Array(Float64), skipping nils
    def self.extract_numeric(df : DataFrame, col_name : String) : Array(Float64)
      col = df[col_name]
      result = [] of Float64
      col.values.each do |v|
        if f = to_float64(v)
          result << f
        end
      end
      result
    end

    # Extract string column for x-axis labels
    def self.extract_strings(df : DataFrame, col_name : String) : Array(String)
      col = df[col_name]
      col.values.map { |v| v.nil? ? "" : v.to_s }
    end

    # Apply default size to plot
    def self.apply_defaults(plot : Cryplot::Plot) : Cryplot::Plot
      plot.size(PlotConfig.default_width, PlotConfig.default_height)
      plot
    end
  end

  module DataFrame
    # Draw a line plot with x and y columns
    # Set sorted: true to sort by x values (useful for time series)
    def plot_line(x : String, y : String, *, sorted : Bool = false) : Cryplot::Plot
      df = sorted ? self.sort_by(x) : self
      x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(df, x, y)

      plot = Cryplot.plot
      plot.draw_curve(x_vals, y_vals).label(y)
      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Draw a line plot with multiple y series
    # Set sorted: true to sort by x values (useful for time series)
    def plot_line(x : String, *y_cols : String, sorted : Bool = false) : Cryplot::Plot
      df = sorted ? self.sort_by(x) : self
      x_data = PlotDataExtractor.extract_numeric(df, x)

      plot = Cryplot.plot
      y_cols.each do |y_col|
        y_data = PlotDataExtractor.extract_numeric(df, y_col)
        # Align lengths
        len = Math.min(x_data.size, y_data.size)
        plot.draw_curve(x_data[0, len], y_data[0, len]).label(y_col)
      end
      plot.xlabel(x)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Draw a scatter plot
    def plot_scatter(x : String, y : String) : Cryplot::Plot
      x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(self, x, y)

      plot = Cryplot.plot
      plot.draw_points(x_vals, y_vals).label(y)
      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Draw a bar chart
    def plot_bar(x : String, y : String) : Cryplot::Plot
      x_labels = PlotDataExtractor.extract_strings(self, x)
      y_vals = PlotDataExtractor.extract_numeric(self, y)

      plot = Cryplot.plot
      plot.draw_boxes(x_labels, y_vals).label(y)
      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Draw a histogram
    def plot_histogram(column : String, bins : Int32 = 10) : Cryplot::Plot
      values = PlotDataExtractor.extract_numeric(self, column)
      if values.empty?
        plot = Cryplot.plot
        return PlotDataExtractor.apply_defaults(plot)
      end

      min_val = values.min
      max_val = values.max
      range = max_val - min_val

      # Handle edge case where all values are the same
      if range == 0
        bin_width = 1.0
      else
        bin_width = range / bins
      end

      # Count values in each bin
      counts = Array(Float64).new(bins, 0.0)
      bin_centers = Array(Float64).new(bins) { |i| min_val + (i + 0.5) * bin_width }

      values.each do |v|
        bin_idx = ((v - min_val) / bin_width).to_i
        bin_idx = bins - 1 if bin_idx >= bins # Handle max value edge case
        counts[bin_idx] += 1.0
      end

      plot = Cryplot.plot
      plot.draw_boxes(bin_centers, counts).label(column)
      plot.xlabel(column)
      plot.ylabel("Count")
      plot.box_width_relative(0.9)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Draw a box plot for one or more columns
    # Note: Cryplot doesn't have native box plot support, so we simulate with error bars
    def plot_box(*columns : String) : Cryplot::Plot
      plot = Cryplot.plot

      columns.each_with_index do |col_name, idx|
        values = PlotDataExtractor.extract_numeric(self, col_name).sort
        next if values.empty?

        n = values.size
        q1_idx = (n * 0.25).to_i
        q2_idx = (n * 0.5).to_i
        q3_idx = (n * 0.75).to_i

        q1 = values[q1_idx]
        median = values[q2_idx]
        q3 = values[q3_idx]
        min_val = values.first
        max_val = values.last

        # Draw as error bars: x position, median, lower whisker, upper whisker
        x_pos = [idx.to_f64 + 1]
        y_median = [median]
        y_low = [q1 - min_val]
        y_high = [max_val - q3]

        plot.draw_boxes_with_error_bars_y(x_pos, y_median, y_low, y_high).label(col_name)
      end

      plot.ylabel("Value")
      PlotDataExtractor.apply_defaults(plot)
    end

    # Quick bar chart from value_counts result
    # Usage: df.value_counts("category").plot_value_counts
    def plot_value_counts(label_col : String? = nil, count_col : String = "n") : Cryplot::Plot
      # Auto-detect label column (first non-count column)
      x_col = label_col || (names - [count_col]).first

      plot_bar(x_col, count_col)
    end

    # Plot correlation matrix as a heatmap for numeric columns
    def plot_correlation : Cryplot::Plot
      # Get numeric columns only
      numeric_cols = cols.select { |c|
        c.is_a?(Float64Col) || c.is_a?(Int32Col) || c.is_a?(Int64Col)
      }.map(&.name)

      raise ArgumentError.new("Need at least 2 numeric columns for correlation matrix") if numeric_cols.size < 2

      n = numeric_cols.size

      # Calculate correlation matrix
      correlations = Array(Array(Float64)).new(n) { Array(Float64).new(n, 0.0) }

      numeric_cols.each_with_index do |col1, i|
        numeric_cols.each_with_index do |col2, j|
          correlations[i][j] = calculate_correlation(col1, col2)
        end
      end

      plot = Cryplot.plot
      plot.heatmap_palette(:diverging)
      plot.colorbar_label("Correlation")
      plot.draw_heatmap_labeled(correlations, numeric_cols, numeric_cols, {-1.0, 1.0})
      plot.title("Correlation Matrix")
      PlotDataExtractor.apply_defaults(plot)
    end

    # Calculate Pearson correlation between two columns
    private def calculate_correlation(col1 : String, col2 : String) : Float64
      x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(self, col1, col2)
      return 0.0 if x_vals.size < 2

      n = x_vals.size.to_f64
      sum_x = x_vals.sum
      sum_y = y_vals.sum
      sum_xy = x_vals.zip(y_vals).sum { |x, y| x * y }
      sum_x2 = x_vals.sum { |x| x * x }
      sum_y2 = y_vals.sum { |y| y * y }

      numerator = n * sum_xy - sum_x * sum_y
      denominator = Math.sqrt((n * sum_x2 - sum_x ** 2) * (n * sum_y2 - sum_y ** 2))

      return 0.0 if denominator == 0
      numerator / denominator
    end

    # Pairplot - grid of scatter plots for all numeric column pairs
    # Diagonal shows histograms, off-diagonal shows scatter plots
    def plot_pairplot : Cryplot::Figure
      numeric_cols = cols.select { |c|
        c.is_a?(Float64Col) || c.is_a?(Int32Col) || c.is_a?(Int64Col)
      }.map(&.name)

      raise ArgumentError.new("Need at least 2 numeric columns for pairplot") if numeric_cols.size < 2

      n = numeric_cols.size
      plots = [] of Cryplot::PlotXD

      numeric_cols.each_with_index do |row_col, i|
        numeric_cols.each_with_index do |col_col, j|
          plot = Cryplot.plot
          plot.legend.hide

          if i == j
            # Diagonal: histogram
            values = PlotDataExtractor.extract_numeric(self, row_col)
            unless values.empty?
              min_val, max_val = values.min, values.max
              bins = 15
              bin_width = (max_val - min_val) / bins
              bin_width = 1.0 if bin_width == 0
              counts = Array(Float64).new(bins, 0.0)
              bin_centers = Array(Float64).new(bins) { |b| min_val + (b + 0.5) * bin_width }
              values.each do |v|
                bin_idx = ((v - min_val) / bin_width).to_i.clamp(0, bins - 1)
                counts[bin_idx] += 1.0
              end
              plot.draw_boxes(bin_centers, counts).label_none
              plot.box_width_relative(0.9)
            end
          else
            # Off-diagonal: scatter
            x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(self, col_col, row_col)
            plot.draw_points(x_vals, y_vals).label_none unless x_vals.empty?
          end

          # Labels only on edges
          plot.xlabel(col_col) if i == n - 1
          plot.ylabel(row_col) if j == 0

          plots << plot.as(Cryplot::PlotXD)
        end
      end

      # Build n x n grid
      multi = Array(Array(Cryplot::PlotXD)).new(n) do |r|
        Array(Cryplot::PlotXD).new(n) { |c| plots[r * n + c] }
      end

      fig = Cryplot.figure(multi)
      fig.size(PlotConfig.default_width, PlotConfig.default_height)
      fig
    end

    # Scatter plot with linear regression line and R² annotation
    def plot_regression(x : String, y : String) : Cryplot::Plot
      x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(self, x, y)

      plot = Cryplot.plot
      return PlotDataExtractor.apply_defaults(plot) if x_vals.size < 2

      # Draw scatter points
      plot.draw_points(x_vals, y_vals).label(y)

      # Calculate linear regression: y = mx + b
      n = x_vals.size.to_f64
      sum_x = x_vals.sum
      sum_y = y_vals.sum
      sum_xy = x_vals.zip(y_vals).sum { |xv, yv| xv * yv }
      sum_x2 = x_vals.sum { |xv| xv * xv }

      m = (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)
      b = (sum_y - m * sum_x) / n

      # Calculate R²
      y_mean = sum_y / n
      ss_tot = y_vals.sum { |yv| (yv - y_mean) ** 2 }
      ss_res = x_vals.zip(y_vals).sum { |xv, yv| (yv - (m * xv + b)) ** 2 }
      r_squared = ss_tot > 0 ? 1.0 - (ss_res / ss_tot) : 0.0

      # Draw regression line
      x_min, x_max = x_vals.min, x_vals.max
      line_x = [x_min, x_max]
      line_y = [m * x_min + b, m * x_max + b]
      plot.draw_curve(line_x, line_y).label("R² = #{r_squared.round(3)}")

      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Stacked bar chart for multiple y columns
    def plot_stacked_bar(x : String, *y_cols : String) : Cryplot::Plot
      x_labels = PlotDataExtractor.extract_strings(self, x)

      plot = Cryplot.plot
      plot.gnuplot("set style data histogram")
      plot.gnuplot("set style histogram rowstacked")
      plot.gnuplot("set style fill solid border -1")

      y_cols.each do |y_col|
        y_vals = PlotDataExtractor.extract_numeric(self, y_col)
        plot.draw_boxes(x_labels, y_vals).label(y_col)
      end

      plot.xlabel(x)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Grouped bar chart - bars side by side for each category
    def plot_grouped_bar(x : String, *y_cols : String) : Cryplot::Plot
      x_labels = PlotDataExtractor.extract_strings(self, x)

      plot = Cryplot.plot
      plot.gnuplot("set style data histogram")
      plot.gnuplot("set style histogram cluster gap 1")
      plot.gnuplot("set style fill solid border -1")

      y_cols.each do |y_col|
        y_vals = PlotDataExtractor.extract_numeric(self, y_col)
        plot.draw_boxes(x_labels, y_vals).label(y_col)
      end

      plot.xlabel(x)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Heatmap from three columns (x categories, y categories, values)
    # Pivots the data and displays as heatmap
    def plot_heatmap(x : String, y : String, value : String) : Cryplot::Plot
      # Get unique x and y values
      x_labels = PlotDataExtractor.extract_strings(self, x).uniq
      y_labels = PlotDataExtractor.extract_strings(self, y).uniq

      # Build matrix
      matrix = Array(Array(Float64)).new(y_labels.size) { Array(Float64).new(x_labels.size, 0.0) }

      num_row.times do |i|
        x_val = self[x][i].to_s
        y_val = self[y][i].to_s
        z_val = PlotDataExtractor.to_float64(self[value][i]) || 0.0

        x_idx = x_labels.index(x_val)
        y_idx = y_labels.index(y_val)

        if x_idx && y_idx
          matrix[y_idx][x_idx] = z_val
        end
      end

      plot = Cryplot.plot
      plot.heatmap_palette(:sequential)
      plot.colorbar_label(value)
      plot.draw_heatmap_labeled(matrix, y_labels, x_labels, nil)
      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Distribution plot - histogram with optional KDE overlay
    def plot_distribution(column : String, bins : Int32 = 20, *, kde : Bool = true) : Cryplot::Plot
      values = PlotDataExtractor.extract_numeric(self, column)
      if values.empty?
        plot = Cryplot.plot
        return PlotDataExtractor.apply_defaults(plot)
      end

      min_val = values.min
      max_val = values.max
      range = max_val - min_val
      bin_width = range > 0 ? range / bins : 1.0

      # Build histogram
      counts = Array(Float64).new(bins, 0.0)
      bin_centers = Array(Float64).new(bins) { |i| min_val + (i + 0.5) * bin_width }

      values.each do |v|
        bin_idx = ((v - min_val) / bin_width).to_i.clamp(0, bins - 1)
        counts[bin_idx] += 1.0
      end

      # Normalize to density for KDE comparison
      total = counts.sum
      density = counts.map { |c| c / (total * bin_width) }

      plot = Cryplot.plot
      plot.draw_boxes(bin_centers, density).label("Histogram")
      plot.box_width_relative(0.9)

      if kde && values.size > 1
        # Simple KDE using Gaussian kernel
        kde_x = Array(Float64).new(100) { |i| min_val + i * range / 99 }
        bandwidth = 1.06 * Math.sqrt(variance(values)) * (values.size.to_f64 ** -0.2)
        bandwidth = bin_width if bandwidth <= 0

        kde_y = kde_x.map do |x|
          values.sum { |v| Math.exp(-0.5 * ((x - v) / bandwidth) ** 2) } / (values.size * bandwidth * Math.sqrt(2 * Math::PI))
        end

        plot.draw_curve(kde_x, kde_y).label("KDE").line_width(2)
      end

      plot.xlabel(column)
      plot.ylabel("Density")
      PlotDataExtractor.apply_defaults(plot)
    end

    # Helper: calculate variance
    private def variance(values : Array(Float64)) : Float64
      return 0.0 if values.size < 2
      mean = values.sum / values.size
      values.sum { |v| (v - mean) ** 2 } / (values.size - 1)
    end

    # Stacked area chart for time series composition
    def plot_area(x : String, *y_cols : String) : Cryplot::Plot
      x_data = PlotDataExtractor.extract_numeric(self, x)

      plot = Cryplot.plot

      # For stacked area, we need cumulative sums
      cumulative = Array(Float64).new(x_data.size, 0.0)

      y_cols.each do |y_col|
        y_data = PlotDataExtractor.extract_numeric(self, y_col)
        len = Math.min(x_data.size, y_data.size)

        # Previous cumulative becomes the baseline
        baseline = cumulative[0, len].dup

        # Add current values to cumulative
        len.times { |i| cumulative[i] += y_data[i] }

        # Draw filled area between baseline and cumulative
        plot.draw_curves_filled(x_data[0, len], baseline, cumulative[0, len]).label(y_col)
      end

      plot.xlabel(x)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Scatter/line plot with error bars
    def plot_errorbar(x : String, y : String, yerr : String) : Cryplot::Plot
      x_vals = PlotDataExtractor.extract_numeric(self, x)
      y_vals = PlotDataExtractor.extract_numeric(self, y)
      err_vals = PlotDataExtractor.extract_numeric(self, yerr)

      len = [x_vals.size, y_vals.size, err_vals.size].min

      plot = Cryplot.plot
      plot.draw_error_bars_y(x_vals[0, len], y_vals[0, len], err_vals[0, len]).label(y)
      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Stem/lollipop chart
    def plot_stem(x : String, y : String) : Cryplot::Plot
      x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(self, x, y)

      plot = Cryplot.plot
      plot.draw_impulses(x_vals, y_vals).label(y)
      # Add points at the top
      plot.draw_points(x_vals, y_vals).label_none
      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Pie chart
    def plot_pie(label_col : String, value_col : String) : Cryplot::Plot
      labels = PlotDataExtractor.extract_strings(self, label_col)
      values = PlotDataExtractor.extract_numeric(self, value_col)

      total = values.sum
      return Cryplot.plot if total == 0

      plot = Cryplot.plot

      # Gnuplot pie chart setup
      plot.gnuplot("unset border")
      plot.gnuplot("unset tics")
      plot.gnuplot("unset key")
      plot.gnuplot("set size ratio 1")

      # Calculate angles and draw sectors
      start_angle = 0.0
      colors = ["#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ff7f00", "#ffff33", "#a65628", "#f781bf"]

      labels.each_with_index do |label, i|
        next if i >= values.size
        fraction = values[i] / total
        end_angle = start_angle + fraction * 360

        color = colors[i % colors.size]
        mid_angle = (start_angle + end_angle) / 2 * Math::PI / 180

        # Draw pie sector using object circle with arc
        plot.gnuplot("set object #{i + 1} circle at 0,0 size 1 arc [#{start_angle}:#{end_angle}] fc rgb '#{color}' fs solid front")

        # Add label
        label_r = 0.7
        lx = label_r * Math.cos(mid_angle)
        ly = label_r * Math.sin(mid_angle)
        pct = (fraction * 100).round(1)
        plot.gnuplot("set label #{i + 1} '#{label}\\n#{pct}%' at #{lx},#{ly} center front")

        start_angle = end_angle
      end

      plot.gnuplot("set xrange [-1.2:1.2]")
      plot.gnuplot("set yrange [-1.2:1.2]")
      # Need a dummy plot command
      plot.draw("0", "", "").label_none

      PlotDataExtractor.apply_defaults(plot)
    end

    # Hexagonal binning for large datasets
    def plot_hexbin(x : String, y : String, bins : Int32 = 20) : Cryplot::Plot
      x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(self, x, y)

      plot = Cryplot.plot
      return PlotDataExtractor.apply_defaults(plot) if x_vals.empty?

      x_min, x_max = x_vals.min, x_vals.max
      y_min, y_max = y_vals.min, y_vals.max

      # Create hex grid and count points
      x_step = (x_max - x_min) / bins
      y_step = (y_max - y_min) / bins

      # Simple grid binning (approximation of hexbin)
      counts = Hash({Int32, Int32}, Int32).new(0)
      x_vals.zip(y_vals).each do |xv, yv|
        bx = ((xv - x_min) / x_step).to_i.clamp(0, bins - 1)
        by = ((yv - y_min) / y_step).to_i.clamp(0, bins - 1)
        counts[{bx, by}] += 1
      end

      # Convert to arrays for plotting
      px = [] of Float64
      py = [] of Float64
      pz = [] of Float64
      counts.each do |(bx, by), count|
        px << x_min + (bx + 0.5) * x_step
        py << y_min + (by + 0.5) * y_step
        pz << count.to_f64
      end

      plot.heatmap_palette(:viridis)
      plot.draw_scatter_color(px, py, pz).label_none
      plot.colorbar_label("Count")
      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Q-Q plot for normality check
    def plot_qq(column : String) : Cryplot::Plot
      values = PlotDataExtractor.extract_numeric(self, column).sort

      plot = Cryplot.plot
      return PlotDataExtractor.apply_defaults(plot) if values.size < 2

      n = values.size

      # Calculate theoretical quantiles (standard normal)
      theoretical = Array(Float64).new(n) do |i|
        p = (i + 0.5) / n
        # Approximation of inverse normal CDF
        qnorm(p)
      end

      # Standardize sample values
      mean = values.sum / n
      std = Math.sqrt(variance(values))
      std = 1.0 if std == 0

      sample_quantiles = values.map { |v| (v - mean) / std }

      plot.draw_points(theoretical, sample_quantiles).label("Sample")

      # Add reference line (y = x)
      min_q = [theoretical.min, sample_quantiles.min].min
      max_q = [theoretical.max, sample_quantiles.max].max
      plot.draw_curve([min_q, max_q], [min_q, max_q]).label("Normal")

      plot.xlabel("Theoretical Quantiles")
      plot.ylabel("Sample Quantiles")
      plot.title("Q-Q Plot: #{column}")
      PlotDataExtractor.apply_defaults(plot)
    end

    # Approximation of inverse normal CDF (probit function)
    private def qnorm(p : Float64) : Float64
      return -3.0 if p <= 0.001
      return 3.0 if p >= 0.999

      # Rational approximation
      if p < 0.5
        t = Math.sqrt(-2.0 * Math.log(p))
        (2.515517 + 0.802853 * t + 0.010328 * t * t) / (1.0 + 1.432788 * t + 0.189269 * t * t + 0.001308 * t * t * t) - t
      else
        t = Math.sqrt(-2.0 * Math.log(1.0 - p))
        t - (2.515517 + 0.802853 * t + 0.010328 * t * t) / (1.0 + 1.432788 * t + 0.189269 * t * t + 0.001308 * t * t * t)
      end
    end

    # Density plot (KDE only, no histogram)
    def plot_density(*columns : String) : Cryplot::Plot
      plot = Cryplot.plot

      columns.each do |column|
        values = PlotDataExtractor.extract_numeric(self, column)
        next if values.size < 2

        min_val = values.min
        max_val = values.max
        range = max_val - min_val
        range = 1.0 if range == 0

        # KDE calculation
        kde_x = Array(Float64).new(100) { |i| min_val + i * range / 99 }
        bandwidth = 1.06 * Math.sqrt(variance(values)) * (values.size.to_f64 ** -0.2)
        bandwidth = range / 10 if bandwidth <= 0

        kde_y = kde_x.map do |x|
          values.sum { |v| Math.exp(-0.5 * ((x - v) / bandwidth) ** 2) } / (values.size * bandwidth * Math.sqrt(2 * Math::PI))
        end

        plot.draw_curve(kde_x, kde_y).label(column).line_width(2)
      end

      plot.xlabel("Value")
      plot.ylabel("Density")
      PlotDataExtractor.apply_defaults(plot)
    end

    # Returns a PlotBuilder for more complex plot configurations
    def plot : PlotBuilder
      PlotBuilder.new(self)
    end
  end

  # Plotting extensions for GroupedDataFrame
  private struct GroupedDataFrame
    # Draw scatter plot with each group as a separate series
    def plot_scatter(x : String, y : String) : Cryplot::Plot
      grps = self.groups
      group_cols = self.by

      plot = Cryplot.plot

      grps.each_with_index do |group_df, idx|
        x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(group_df, x, y)
        next if x_vals.empty?

        # Try to get a label from the group
        label = "Group #{idx + 1}"
        if group_df.num_row > 0 && group_cols.size > 0
          label = group_cols.map { |c| group_df[c][0].to_s }.join(", ")
        end

        plot.draw_points(x_vals, y_vals).label(label)
      end

      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Draw line plot with each group as a separate series
    def plot_line(x : String, y : String, *, sorted : Bool = false) : Cryplot::Plot
      grps = self.groups
      group_cols = self.by

      plot = Cryplot.plot

      grps.each_with_index do |group_df, idx|
        df = sorted ? group_df.sort_by(x) : group_df
        x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(df, x, y)
        next if x_vals.empty?

        label = "Group #{idx + 1}"
        if group_df.num_row > 0 && group_cols.size > 0
          label = group_cols.map { |c| group_df[c][0].to_s }.join(", ")
        end

        plot.draw_curve(x_vals, y_vals).label(label)
      end

      plot.xlabel(x)
      plot.ylabel(y)
      PlotDataExtractor.apply_defaults(plot)
    end

    # Create faceted scatter plots (small multiples) - one subplot per group
    def plot_facet_scatter(x : String, y : String) : Cryplot::Figure
      grps = self.groups
      group_cols = self.by

      plots = grps.map_with_index do |group_df, idx|
        x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(group_df, x, y)

        label = "Group #{idx + 1}"
        if group_df.num_row > 0 && group_cols.size > 0
          label = group_cols.map { |c| group_df[c][0].to_s }.join(", ")
        end

        plot = Cryplot.plot
        plot.draw_points(x_vals, y_vals).label_none
        plot.xlabel(x)
        plot.ylabel(y)
        plot.title(label)
        plot.legend.hide
        plot.as(Cryplot::PlotXD)
      end

      # Arrange in grid
      cols = Math.sqrt(plots.size).ceil.to_i
      rows = (plots.size.to_f / cols).ceil.to_i

      # Build MultiPlots array (empty plots are now safe)
      multi = Array(Array(Cryplot::PlotXD)).new(rows) do |r|
        Array(Cryplot::PlotXD).new(cols) do |c|
          idx = r * cols + c
          idx < plots.size ? plots[idx] : Cryplot.plot.as(Cryplot::PlotXD)
        end
      end

      fig = Cryplot.figure(multi)
      fig.size(PlotConfig.default_width, PlotConfig.default_height)
      fig
    end

    # Create faceted line plots (small multiples) - one subplot per group
    def plot_facet_line(x : String, y : String, *, sorted : Bool = false) : Cryplot::Figure
      grps = self.groups
      group_cols = self.by

      plots = grps.map_with_index do |group_df, idx|
        df = sorted ? group_df.sort_by(x) : group_df
        x_vals, y_vals = PlotDataExtractor.extract_numeric_pair(df, x, y)

        label = "Group #{idx + 1}"
        if group_df.num_row > 0 && group_cols.size > 0
          label = group_cols.map { |c| group_df[c][0].to_s }.join(", ")
        end

        plot = Cryplot.plot
        plot.draw_curve(x_vals, y_vals).label_none
        plot.xlabel(x)
        plot.ylabel(y)
        plot.title(label)
        plot.legend.hide
        plot.as(Cryplot::PlotXD)
      end

      # Arrange in grid
      cols = Math.sqrt(plots.size).ceil.to_i
      rows = (plots.size.to_f / cols).ceil.to_i

      # Build MultiPlots array (empty plots are now safe)
      multi = Array(Array(Cryplot::PlotXD)).new(rows) do |r|
        Array(Cryplot::PlotXD).new(cols) do |c|
          idx = r * cols + c
          idx < plots.size ? plots[idx] : Cryplot.plot.as(Cryplot::PlotXD)
        end
      end

      fig = Cryplot.figure(multi)
      fig.size(PlotConfig.default_width, PlotConfig.default_height)
      fig
    end
  end

  # Builder class for more complex plot configurations
  class PlotBuilder
    @df : DataFrame
    @plot_type : Symbol = :line
    @x_col : String = ""
    @y_cols : Array(String) = [] of String
    @title_text : String = ""
    @x_label : String = ""
    @y_label : String = ""

    def initialize(@df)
    end

    def line(x : String, *y_cols : String) : self
      @plot_type = :line
      @x_col = x
      @y_cols = y_cols.to_a
      @x_label = x if @x_label.empty?
      self
    end

    def scatter(x : String, y : String) : self
      @plot_type = :scatter
      @x_col = x
      @y_cols = [y]
      @x_label = x if @x_label.empty?
      @y_label = y if @y_label.empty?
      self
    end

    def bar(x : String, y : String) : self
      @plot_type = :bar
      @x_col = x
      @y_cols = [y]
      @x_label = x if @x_label.empty?
      @y_label = y if @y_label.empty?
      self
    end

    def histogram(column : String, bins : Int32 = 10) : self
      @plot_type = :histogram
      @x_col = column
      @y_cols = [bins.to_s]
      @x_label = column if @x_label.empty?
      @y_label = "Count" if @y_label.empty?
      self
    end

    def title(text : String) : self
      @title_text = text
      self
    end

    def xlabel(text : String) : self
      @x_label = text
      self
    end

    def ylabel(text : String) : self
      @y_label = text
      self
    end

    def build : Cryplot::Plot
      plot = case @plot_type
             when :line
               if @y_cols.size == 1
                 @df.plot_line(@x_col, @y_cols[0])
               else
                 build_multi_line_plot
               end
             when :scatter
               @df.plot_scatter(@x_col, @y_cols[0])
             when :bar
               @df.plot_bar(@x_col, @y_cols[0])
             when :histogram
               bins = @y_cols[0]?.try(&.to_i?) || 10
               @df.plot_histogram(@x_col, bins)
             else
               @df.plot_line(@x_col, @y_cols[0])
             end

      plot.title(@title_text) unless @title_text.empty?
      plot.xlabel(@x_label) unless @x_label.empty?
      plot.ylabel(@y_label) unless @y_label.empty?
      plot
    end

    private def build_multi_line_plot : Cryplot::Plot
      case @y_cols.size
      when 2
        @df.plot_line(@x_col, @y_cols[0], @y_cols[1])
      when 3
        @df.plot_line(@x_col, @y_cols[0], @y_cols[1], @y_cols[2])
      when 4
        @df.plot_line(@x_col, @y_cols[0], @y_cols[1], @y_cols[2], @y_cols[3])
      when 5
        @df.plot_line(@x_col, @y_cols[0], @y_cols[1], @y_cols[2], @y_cols[3], @y_cols[4])
      else
        # Fallback for more columns - just use first one
        @df.plot_line(@x_col, @y_cols[0])
      end
    end

    def show
      build.show
    end

    def save(filename : String)
      build.save(filename)
    end
  end
end
