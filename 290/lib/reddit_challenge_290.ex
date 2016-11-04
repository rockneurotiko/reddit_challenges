defmodule RedditChallenge290 do
  use Bitwise, only_operators: true

  defp get(state, key), do: Agent.get(state, &Map.get(&1, key))

  defp put(state, key, value), do: Agent.update(state, &Map.put(&1, key, value))

  defp trans_instr(ins) do
    case ins do
      ["ld", reg, size] -> {:load, reg, size}
      ["out", _, reg] -> {:out, reg}
      ["rlca"] -> {:rlca}
      ["rrca"] -> {:rrca}
      ["djnz", label] -> {:djnz, label}
      [label] -> {:label, label}
      [] -> {:empty}
      x -> {:error, "wat #{x}"}
    end
  end

  defp n_to_stars(n) do
    Integer.to_string(n, 2)
    |> String.Chars.to_string
    |> String.pad_leading(8, "0")
    |> to_charlist
    |> Enum.map(fn x -> if x == 49 do "*" else "." end end)
  end

  def rotl1(n) do
    rn = (n <<< 1 ||| (n >>> 7))
    if rn > 255 do abs(256 - rn) else rn end
  end

  defp rotr1(n) do
    rn = n >>> 1
    if rn <= 0 do n <<< 7 else rn end
  end

  defp eval_instr(ins, state) do
    case ins do
      {:load, reg, size} -> put(state, reg, size)
      {:out, reg} ->
        get(state, reg)
        |> n_to_stars
        |> IO.puts
      {:rlca} ->
        n = get(state, "a")
        put(state, "a", rotl1(n))
      {:rrca} ->
        n = get(state, "a")
        put(state, "a", rotr1(n))
      {:djnz, label} ->
        b = get(state, "b") - 1
        put(state, "b", b)
        if b > 0 do
          stack = get(state, label)
          put(state, label, [])
          put(state, :stack, stack)
        end
      {:label, label} ->
        put(state, label, [])
        put(state, :label, label)
      {:error, msg} -> if get(state, :debug), do: IO.puts "ERROR: #{msg}"
      {:empty} -> :empty
    end
  end

  defp save_instr(ins, state) do
    label = get(state, :label)
    if label do
      st = get(state, label)
      put(state, label, st ++ [ins])
    end
    ins
  end

  defp eval_with_state(state, ins) do
    save_instr(ins, state)
    |> eval_instr(state)
  end

  defp execute([], _) do

  end
  defp execute([x|xs], state) do
    eval_with_state(state, x)
    stack = get(state, :stack)
    put(state, :stack, [])
    execute(stack ++ xs, state)
  end

  defp line_to_inner(line) do
    case Parser.parse(line) do
      {:error, _} ->
        # if get(state, :debug) == :true, do: IO.puts "ERROR: #{line} - #{err}"
        nil
      line ->
        trans_instr(line)
    end
  end

  defp load_all_in() do
    IO.stream(:stdio, :line)
    |> Stream.map(&line_to_inner(&1))
    |> Stream.filter(fn x -> x != nil end)
    |> Enum.to_list
  end

  def main(_) do
    {:ok, state} = Agent.start_link(fn -> %{} end)
    put(state, :debug, :true)
    put(state, :stack, [])

    load_all_in()
    |> execute(state)
  end
end
