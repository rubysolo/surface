defmodule Surface.LiveComponent do
  @moduledoc """
  A live (stateless or stateful) component. A wrapper around `Phoenix.LiveComponent`.

  ## Example

      defmodule Dialog do
        use Surface.LiveComponent

        property title, :string, required: true

        def mount(socket) do
          {:ok, assign(socket, show: false)}
        end

        def render(assigns) do
          ~H"\""
          <div class={{ "modal", isActive: @show }}>
            <div class="modal-background"></div>
            <div class="modal-card">
              <header class="modal-card-head">
                <p class="modal-card-title">{{ @title }}</p>
              </header>
              <section class="modal-card-body">
                {{ @inner_content.() }}
              </section>
              <footer class="modal-card-foot" style="justify-content: flex-end">
                <Button click="hide">Ok</Button>
              </footer>
            </div>
          </div>
          "\""
        end

        # Public API

        def show(dialog_id) do
          send_update(__MODULE__, id: dialog_id, show: true)
        end

        # Event handlers

        def handle_event("show", _, socket) do
          {:noreply, assign(socket, show: true)}
        end

        def handle_event("hide", _, socket) do
          {:noreply, assign(socket, show: false)}
        end
      end
  """

  defmacro __using__(_) do
    quote do
      use Phoenix.LiveComponent
      use Surface.BaseComponent
      use Surface.EventValidator
      import Phoenix.HTML

      @behaviour unquote(__MODULE__)

      def translator do
        Surface.Translator.LiveComponentTranslator
      end
    end
  end

  @doc """
  This optional callback is invoked in order to set up a
  context that can be retrieved for any descendent component.
  """
  @callback begin_context(props :: map()) :: map()

  @doc """
  This optional callback is invoked in order to clean up a
  context previously created in the `c:begin_context/1`.
  """
  @callback end_context(props :: map()) :: map()

  @doc """
  The same as `Phoenix.LiveComponent.mount/1`.
  """
  @callback mount(socket :: Socket.t()) ::
    {:ok, Socket.t()} | {:ok, Socket.t(), keyword()}

  @doc """
  The same as `Phoenix.LiveComponent.preload/1`.
  """
  @callback preload([Socket.assigns()]) :: [Socket.assigns()]

  @doc """
  The same as `Phoenix.LiveComponent.update/2`.
  """
  @callback update(Socket.assigns(), socket :: Socket.t()) ::
    {:ok, Socket.t()}

  @doc """
  The same as `Phoenix.LiveComponent.render/1`.
  """
  @callback render(assigns :: Socket.assigns()) :: Phoenix.LiveView.Rendered.t()

  @doc """
  The same as `Phoenix.LiveComponent.handle_event/3`.
  """
  @callback handle_event(event :: binary, Phoenix.LiveView.unsigned_params, socket :: Socket.t()) ::
    {:noreply, Socket.t()}

  @optional_callbacks preload: 1, mount: 1, update: 2, handle_event: 3, begin_context: 1, end_context: 1
end
