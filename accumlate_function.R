


# Tge accumlate function
library(purrr)


# The same function on rep
1:3 |> accumulate( `+`)

c(1,2,3) |> cumsum()

1, 1+2,1+2+3

letters[1:4] |> accumulate(paste)

paste_alt <- function(acc, nxt) paste(acc, nxt, sep = ".")
paste_alt2 <- function(acc, nxt) paste( nxt,acc, sep = ".")

letters[1:4] |> accumulate(paste_alt)
letters[1:4] |> accumulate(paste_alt, .dir = "backward")
letters[1:4] |> accumulate(paste_alt2, .dir = "backward")

paste3 <- function(out, input, sep = ".") {
    if (nchar(out) > 6) {
        return(done(out))
    }
    paste(out, input, sep = sep)
}

letters |> accumulate( paste3)


paste4 <- function(out, input, sep = ".") {
    if (input == "f") {
        return(done())
    }
    paste(out, input, sep = sep)
}
letters |> accumulate(paste4)

# Creating random walk data with drift 
r_number <- rnorm(10)

r_number |> accumulate( \(acc, nxt) .05 + acc + nxt )

list_df <- map(1:5, \(i) rnorm(100)) |>
    set_names(paste0("sim", 1:5)) |>
    map(\(l) accumulate(l, \(acc, nxt) .05 + acc + nxt)) |>
    map(\(x) tibble(value = x, step = 1:100)) 

bind_rows(list_df, .id = "simulation") |> 
    ggplot(aes(x = step, y = value)) +
    geom_line(aes(color = simulation)) +
    ggtitle("Simulations of a random walk with drift")


## 
1:4 |> reduce(`+`)

letters[1:3] |> reduce( ~paste(.x, sep = ".")), .dir = "forward")



# -------------------------------------------------------------------------


# Pascal's Triangle
row <- c(1, 3, 3, 1)
c(0, row) + c(row, 0)


accumulate(1:6, ~ c(0, .) + c(., 0), .init = 1)






