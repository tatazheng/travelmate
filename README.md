# TravelMate MVP

A responsive React + Vite travel planner with trip overview, day-by-day itinerary, interactive OpenStreetMap pins/routes, Google Maps directions links, flight/hotel/tour records, and editable place cards. It works immediately in local browser mode using localStorage.

## Run locally

1. Install Node.js 20+.
2. In this folder run `npm install`.
3. Run `npm run dev` and open the URL Vite prints.
4. Run `npm run build` to create the production bundle in `dist/`.

## Current MVP scope

- Create and edit trips, dates and destinations.
- Add, edit and delete itinerary places with day/time, image URL, address, opening hours, admission price, access notes, and coordinates.
- Day selector and route map. Add latitude/longitude for accurate pins; the route connects stops in itinerary order.
- Open a route or individual destination in Google Maps for turn-by-turn navigation.
- Add flight, hotel and local tour records.
- Local persistence in the browser.
- Optional Supabase email magic-link authentication scaffold.

## Cloud sharing setup

The UI is ready for a Supabase project, and `supabase-schema.sql` provides the database/RLS starting point for shared trips. Create a Supabase project, run the SQL in its SQL Editor, copy `.env.example` to `.env`, and add the project URL and anon key. Configure Auth > URL Configuration with your local/deployed app URL. **Important:** the current build does not yet sync trip JSON to Supabase or implement member invitations; those are the next integration tasks before using shared trips across devices. The local Share Trip action currently copies a link only and is not a cloud collaboration feature.

## Maps

- Embedded map uses OpenStreetMap tiles via Leaflet (no map API key required).
- Google Maps is used for external destination and multi-stop directions links.
- Google Maps Directions API / Routes API integration, traffic-aware travel times, transit routing, and route optimization are not yet wired up.

## AI research

AI planning is currently a brief capture UI only. Add a server-side API endpoint and provider key before enabling live AI research. Never expose secret AI keys in VITE_ browser environment variables.

## Before production

Add cloud data sync, invite/join flow, image upload/storage, robust place lookup/geocoding, verified opening-hours and ticket-price sources, API-backed routing, budget tracking, export, and tests. Treat hours and prices entered by users as unverified until checked with the venue.

## Share a trip

With the Supabase schema installed and a signed-in owner, click **Share trip** and send the copied URL to a trusted companion. The recipient opens the link, signs in with their email magic link, and the app calls `join_trip` to add them as an editor. Trip data then syncs through the `trips` table. The MVP currently grants editor access to anyone holding the share link; share it privately. There is no viewer role selector or email allow-list yet.
