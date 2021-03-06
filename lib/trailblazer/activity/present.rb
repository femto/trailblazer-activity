require "hirb"

module Trailblazer
  class Activity < Module

    # Task < Array
    # [ input, ..., output ]

    module Trace
      # TODO: make this simpler.
      module Present
        module_function

        def default_renderer(stack:, level:, input:, name:, **)
          [ level, %{#{name}} ]
        end

        def call(stack, level: 1, tree: [], renderer: method(:default_renderer), **options)
          tree(stack.to_a, level, tree: tree, renderer: renderer, **options)
        end

        def tree(stack, level, tree: tree, **options)
          tree_for(stack, level, options.merge(tree: tree))

          Hirb::Console.format_output(tree, class: :tree, type: :directory)
        end

        def tree_for(stack, level, tree:, renderer: ,**options)
          stack.each do |lvl| # always a Stack::Task[input, ..., output]
            input, output, nested = Trace::Level.input_output_nested_for_level(lvl)

            task = input.task

            graph = Introspect::Graph(input.activity)

            name = (node = graph.find { |node| node[:task] == task }) ? node[:id] : task
            name ||= task # FIXME: bullshit

            tree << renderer.(stack: stack, level: level, input: input, name: name, **options)

            if nested.any? # nesting
              tree_for(nested, level + 1, options.merge(tree: tree, renderer: renderer))
            end

            tree
          end
        end

        def color_map
          {
            Trailblazer::Activity::Start => :blue,
            Trailblazer::Activity::End   => :pink,
            Trailblazer::Activity::Right => :green,
            Trailblazer::Activity::Left  => :red
          }
        end

        def color_table
          {
            red:    31,
            green:  32,
            yellow: 33,
            blue:   34,
            pink:   35
          }
        end
      end
    end
  end
end
