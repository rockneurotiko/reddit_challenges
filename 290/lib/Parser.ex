defmodule Parser do
  use Combine
  import Combine.Parsers.Text

  def parse(line), do: Combine.parse(line, parser)

  defp parser, do: choice([instruction, empty, label_ins])

  defp instruction, do: choice([load, out, rlca, rrca, djnz])

  defp addEof(pars) do
    pars
    |> ignore(option(spaces))
    |> ignore(option(newline))
    |> ignore(eof)
  end

  defp load do
    ignore(spaces)
    |> label(string("ld"), "action")
    |> ignore(spaces)
    |> label(char, "reg")
    |> ignore(string(","))
    |> label(integer, "size")
    |> addEof
  end

  defp out do
    ignore(spaces)
    |> label(string("out"), "action")
    |> ignore(spaces)
    |> ignore(string("("))
    |> label(integer, "size")
    |> ignore(string(")"))
    |> ignore(string(","))
    |> label(char, "reg")
    |> addEof
  end

  defp rlca do
    ignore(spaces)
    |> label(string("rlca"), "right shift")
    |> addEof
  end

  defp rrca do
    ignore(spaces)
    |> label(string("rrca"), "right shift")
    |> addEof
  end

  defp djnz do
    ignore(spaces)
    |> label(string("djnz"), "right shift")
    |> ignore(spaces)
    |> label(word, "label")
    |> addEof
  end

  defp empty do
    ignore(option(spaces))
    |> addEof
  end

  defp label_ins do
    label(word, "label")
    |> ignore(char(":"))
    |> addEof
  end
end
