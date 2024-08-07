from playwright.sync_api import sync_playwright, expect

with sync_playwright() as p:
    browser = p.chromium.launch()

    context = browser.new_context()
    context.set_default_timeout(30000)
    context.set_default_navigation_timeout(30000)
    context.on(
        "weberror", lambda web_error: print(f"ex: {web_error.error}")
    )
    context.tracing.start(screenshots=True, snapshots=True)
    page = context.new_page()

    try:
        print("Login page")
        page.goto("http://monitoring:3000/login")
        # page.reload()
        page.get_by_role("link", name="Sign in with Authentik").click()

        print("Enter username")
        page.get_by_placeholder("Email or Username").fill("akadmin")
        page.get_by_role("button", name="Log in").click()

        # page.reload()
        print("Enter password")
        page.get_by_placeholder("Please enter your password").fill("password")
        page.get_by_role("button", name="Continue").click()

        print("Consent page")
        page.get_by_role("button", name="Continue").click()

        print("Grafana landing page")
        x = expect(page.get_by_role("heading", name="Starred dashboards"))
        x.to_be_visible(timeout=30000)
    except Exception as e:
        raise e
    finally:
        context.tracing.stop(path="/tmp/trace.zip")
        context.close()
        browser.close()
