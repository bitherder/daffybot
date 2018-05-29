defmodule Daffybot.Move do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    movement_gpio_pins = Application.get_env(:daffybot, :movement_gpio_pins)
    movement_pids = movement_pids(movement_gpio_pins)

    sleep(self(), 6000)

    forward(self())
    sleep(self(), 1000)
    stop(self())

    sleep(self(), 100)

    right(self())
    sleep(self(), 100)
    stop(self())

    sleep(self(), 100)

    forward(self())
    sleep(self(), 1000)
    stop(self())

    sleep(self(), 100)

    left(self())
    sleep(self(), 100)
    stop(self())

    sleep(self(), 100)

    forward(self())
    sleep(self(), 1000)
    stop(self())

    {:ok, movement_pids}
  end

  defp movement_pids(direction_pins) do
    direction_pins
    |> Enum.map(
      fn({direction, pin}) ->
        {:ok, pid} = GpioRpi.start_link(pin, :output)
        {direction, pid}
      end
    )
    |> Map.new
  end

  def forward(pid) do
    GenServer.cast(pid, :forward)
  end

  def left(pid) do
    GenServer.cast(pid, :left)
  end

  def right(pid) do
    GenServer.cast(pid, :right)
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  def sleep(pid, time) do
    GenServer.cast(pid, {:sleep, time})
  end

  def handle_cast(:forward, movement_pids) do
    GpioRpi.write(movement_pids[:left_forward], 1)
    GpioRpi.write(movement_pids[:right_forward], 1)
    {:noreply, movement_pids}
  end

  def handle_cast(:right, movement_pids) do
    GpioRpi.write(movement_pids[:left_forward], 1)
    GpioRpi.write(movement_pids[:right_backward], 1)
    {:noreply, movement_pids}
  end

  def handle_cast(:left, movement_pids) do
    GpioRpi.write(movement_pids[:left_backward], 1)
    GpioRpi.write(movement_pids[:right_forward], 1)
    {:noreply, movement_pids}
  end

  def handle_cast(:stop, movement_pids) do
    GpioRpi.write(movement_pids[:left_forward], 0)
    GpioRpi.write(movement_pids[:left_backward], 0)
    GpioRpi.write(movement_pids[:right_forward], 0)
    GpioRpi.write(movement_pids[:right_backward], 0)
    {:noreply, movement_pids}
  end

  def handle_cast({:sleep, time}, movement_pids) do
    Process.sleep(time)
    {:noreply, movement_pids}
  end
end
