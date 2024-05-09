import { Controller } from "@hotwired/stimulus";
import React from "react";
import { createRoot } from "react-dom/client";
import App from "../components/App";
import { PrivyProvider } from "@privy-io/react-auth";

// Connects to data-controller="react"
export default class extends Controller {
  connect() {
    console.log("React controller connected");
    const app = document.getElementById("app");
    createRoot(app).render(
      <PrivyProvider
        appId="clvxg664y0ihr8ymhm3vvn8rx"
        config={{
          appearance: {
            theme: "light",
            accentColor: "#676FFF",
          },
          embeddedWallets: {
            createOnLogin: "users-without-wallets",
          },
        }}
      >
        <App />
      </PrivyProvider>
    );
  }
}
