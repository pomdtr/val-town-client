import createClient2 from "openapi-fetch";
import { paths } from "./schema";

export default function createClient(options?: {
  baseUrl?: string;
  token?: string;
}) {
  return createClient2<paths>({
    baseUrl: options?.baseUrl ?? "https://api.val.town",
    headers: options?.token ? { Authorization: `Bearer ${options.token}` } : {},
  });
}
