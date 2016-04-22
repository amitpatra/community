defmodule Community.JobController do
  use Community.Web, :controller
  alias Community.Job

  def index(conn, _params) do
    conn
    |> assign(:jobs, approved_jobs)
    |> add_page_action(text: "Post a Job for Free", url: "/jobs/new")
    |> render("index.html")
  end

  def show(conn, %{"id" => id}) do
    case Repo.get_by(Job, id: id, approved: true) do
      nil ->
        conn
        |> put_flash(:error, "There is no approved job with that id")
        |> redirect(to: page_path(conn, :index))
      job ->
        conn
        |> assign(:job, job)
        |> render(:show)
    end
  end

  def new(conn, _params) do
    changeset = Job.changeset(%Job{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"job" => job_params}) do
    changeset = Job.changeset(%Job{}, job_params)
    case Repo.insert(changeset) do
      {:ok, _job} ->
        conn
        |> put_flash(:info, "Job created")
        |> redirect(to: "/")
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Job not created")
        |> render("new.html", changeset: changeset)
    end
  end

  defp approved_jobs do
    Job
    |> Job.approved
    |> Repo.all
  end
end
