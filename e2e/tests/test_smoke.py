from playwright.sync_api import expect


def test_frontend_login(page, frontend_url):
    page.goto(frontend_url)

    expect(page.get_by_role("heading", name="Welcome back")).to_be_visible()
    expect(page.get_by_role("button", name="Sign in")).to_be_visible()


def test_backend_csrf(page, backend_url):
    page.goto(f"{backend_url}/api/auth/csrf/")

    expect(page.locator("body")).to_contain_text("csrfToken")
