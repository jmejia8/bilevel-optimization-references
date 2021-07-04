using PlotlyJS
import DelimitedFiles: readdlm

function interest_over_time()

  years = readdlm(STATISTICS_FILE, Int)[:,1]

  trace1 = histogram(;x=years,
                     marker=attr(color="rgb(49, 130, 189)",opacity=0.6,
                                 line = attr( color="white", width=1 )),
                     xbins = attr(size=1),
                    )
  data = [trace1]
  layout = Layout(;title = "Bilevel Optimization",
                  yaxis=attr(title="Number of papers"),
                  xaxis_tickangle=-45,
                  height=400,
                  barmode="group")
  plt = plot(data, layout)

  fdplotly(json(plt)) # hide
end

