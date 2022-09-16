defmodule LiveChatWeb.MessageLiveTest do
  use LiveChatWeb.ConnCase
  import Phoenix.LiveViewTest
  import Plug.HTML, only: [html_escape: 1]

  test "disconnected and connected mount", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "LiveView Chat"

    {:ok, _view, _html} = live(conn)
  end

  test "name can't be blank", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#new-message-form", message: %{name: "", message: "hello"})
           |> render_submit() =~ html_escape("can't be blank")
  end

  test "message", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#new-message-form", message: %{name: "Guillem", message: ""})
           |> render_submit() =~ html_escape("can't be blank")
  end

  test "message form submitted correctly", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    assert view
           |> form("#new-message-form", message: %{name: "Guillem", message: "Hello World"})
           |> render_submit()

    assert render(view) =~ "<b>Guillem:</b>"
    assert render(view) =~ "Hello World"
  end

  test "handle_info/2", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert render(view)

    LiveChat.Message.create_message(%{"name" => "Guillem", "message" => "Hello World"})

    assert render(view) =~ "<b>Guillem:</b>"
    assert render(view) =~ "Hello World"
  end
end
