defmodule LiveChat.Message do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias LiveChat.Repo
  alias Phoenix.PubSub

  schema "messages" do
    field :message, :string
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message])
    |> validate_required([:name, :message])
  end

  @doc false
  def create_message(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
    |> notify(:message_created)
  end

  @doc false
  def load_last_20_messages() do
    __MODULE__
    |> limit(20)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  # PubSub functions
  def subscribe() do
    PubSub.subscribe(LiveChat.PubSub, "live_chat")
  end

  def notify({:ok, message}, event) do
    PubSub.broadcast(LiveChat.PubSub, "live_chat", {event, message})
  end

  def notify({:error, reason}, _event), do: {:error, reason}
end
