describe('Timer', function()
  it('delays an event', function()
    local event = Testing.fn()
    local delay = 1000

    Timer.delay(event, delay)

    Timer.update(Timer.now())
    expect(event):notToBeCalled()

    Timer.update(Timer.now() + delay)
    expect(event):toBeCalled()
  end)

  it('schedules an event', function()
    local event = Testing.fn()
    local time = Timer.now() + 1000

    Timer.schedule(event, time)

    Timer.update(Timer.now())
    expect(event):notToBeCalled()

    Timer.update(time)
    expect(event):toBeCalled()
  end)
end)
