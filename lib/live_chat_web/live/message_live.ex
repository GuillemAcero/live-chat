defmodule LiveChatWeb.MessageLive do
  use LiveChatWeb, :live_view

  alias LiveChat.Message

  def mount(_params, _session, socket) do
    if connected?(socket), do: Message.subscribe()

    socket =
      socket
      |> assign(changeset: Message.changeset(%Message{}, %{}))
      |> assign(messages: Message.load_last_20_messages() |> Enum.reverse())

     {:ok, socket, temporary_assigns: [messages: []]}
  end

  def render(assigns) do
    LiveChatWeb.MessageView.render("messages.html", assigns)
  end

  def handle_event("new_message", %{"message" => params}, socket) do
    case Message.create_message(params) do
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      :ok ->
        changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info({:message_created, message}, socket) do
    # INFO
    # Normally we would do something like socket.assigns.messages ++ [message]
    {:noreply, assign(socket, messages: [message])}
  end
end
