defmodule Daffybot.Move do
  use GenServer

  alias Pigpiox.GPIO

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    movement_pins = Application.get_env(:daffybot, :movement_gpio_pins)

    set_read_modes(movement_pins)

    sleep(self(), 6000)

    forward(self())
    sleep(self(), 1000)
    stop(self())

    sleep(self(), 2000)

    right(self())
    sleep(self(), 100)
    stop(self())

    sleep(self(), 2000)

    forward(self())
    sleep(self(), 1000)
    stop(self())

    sleep(self(), 2000)

    left(self())
    sleep(self(), 100)
    stop(self())

    sleep(self(), 2000)

    forward(self())
    sleep(self(), 1000)
    stop(self())

    {:ok, movement_pins}
  end

  defp set_read_modes(movement_pins) do
    movement_pins
    |> Enum.each(
      fn({_, pin}) -> GPIO.set_mode(pin, :output) end
    )
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

  def handle_cast(:forward, movement_pins) do
    on(movement_pins[:left_forward])
    on(movement_pins[:right_forward])
    {:noreply, movement_pins}
  end

  def handle_cast(:right, movement_pins) do
    on(movement_pins[:left_forward])
    on(movement_pins[:right_backward])
    {:noreply, movement_pins}
  end

  def handle_cast(:left, movement_pins) do
    on(movement_pins[:left_backward])
    on(movement_pins[:right_forward])
    {:noreply, movement_pins}
  end

  def handle_cast(:stop, movement_pins) do
    off(movement_pins[:left_forward])
    off(movement_pins[:left_backward])
    off(movement_pins[:right_forward])
    off(movement_pins[:right_backward])
    {:noreply, movement_pins}
  end

  def handle_cast({:sleep, time}, movement_pins) do
    Process.sleep(time)
    {:noreply, movement_pins}
  end

  defp on(pin) do
    GPIO.write(pin, 1)
  end

  defp off(pin) do
    GPIO.write(pin, 0)
  end
end
