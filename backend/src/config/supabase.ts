import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { env } from './env.js';
import { ROLES } from '../constants/index.js';
import { AuthenticatedUser } from '../types/auth.types.js';
import { requestContext } from './requestContext.js';

let _rawAdminClient: SupabaseClient<any, any, any> | null = null;
let supabaseDemoClient: SupabaseClient<any, any, any> | null = null;
let supabasePublicClient: SupabaseClient<any, any, any> | null = null;

if (env.SUPABASE_URL && env.SUPABASE_SERVICE_ROLE_KEY) {
  // Public (Production Owner) client
  supabasePublicClient = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
    db: { schema: 'public' },
  });

  // Demo (Effort Career Classes Isolated) client
  supabaseDemoClient = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
    db: { schema: 'demo' },
  });

  const isDemoEnv = env.DEMO_MODE || env.APP_ENV === 'demo';
  _rawAdminClient = isDemoEnv ? supabaseDemoClient : supabasePublicClient;

  console.log(`[Supabase] Initialized clients. Default active schema: [${isDemoEnv ? 'demo' : 'public'}]`);
} else {
  console.warn('⚠️ Supabase URL or Service Role Key missing. Database operations will require credentials.');
}

/**
 * Returns schema-isolated Supabase client based on authenticated user role/trial status or active request context
 */
export function getDb(user?: AuthenticatedUser): SupabaseClient<any, any, any> {
  const currentUser = user || requestContext.getStore()?.user;
  const isDemo = env.DEMO_MODE || env.APP_ENV === 'demo' || currentUser?.role === ROLES.DEMO_ADMIN || currentUser?.isTrial;
  if (isDemo && supabaseDemoClient) {
    return supabaseDemoClient;
  }
  return supabasePublicClient || _rawAdminClient!;
}

/**
 * Proxy supabaseAdmin that dynamically routes queries to the correct schema
 * according to the requesting user's identity (DEMO_ADMIN -> demo.*, OWNER/ADMIN -> public.*).
 */
export const supabaseAdmin = new Proxy({} as SupabaseClient<any, any, any>, {
  get(_target, prop, receiver) {
    const activeClient = getDb();
    if (!activeClient) {
      return undefined;
    }
    if (prop === 'from') {
      return (relation: string) => {
        const globalPublicTables = [
          'whatsapp_templates',
          'whatsapp_messages',
          'whatsapp_queue',
          'whatsapp_settings',
          'whatsapp_logs',
          'whatsapp_auth_state',
        ];
        if (globalPublicTables.includes(relation) && supabasePublicClient) {
          return supabasePublicClient.from(relation);
        }
        return activeClient.from(relation);
      };
    }
    if (prop === 'auth') {
      const origAuth = activeClient.auth;
      if (!env.BACKEND_RPC_SECRET) {
        return origAuth;
      }
      const callAuthRpc = async (action: string, payload: Record<string, any> = {}) => {
        const client = supabasePublicClient || activeClient;
        const { data, error } = await client.rpc('internal_auth_admin_rpc', {
          p_secret: env.BACKEND_RPC_SECRET,
          p_action: action,
          p_payload: payload,
        });
        return { data, error };
      };
      const rpcAdmin = {
        listUsers: async () => {
          const res = await origAuth.admin.listUsers();
          if (!res.error) return res;
          return callAuthRpc('listUsers');
        },
        getUserById: async (id: string) => {
          const res = await origAuth.admin.getUserById(id);
          if (!res.error) return res;
          return callAuthRpc('getUserById', { id });
        },
        createUser: async (attrs: any) => {
          const res = await origAuth.admin.createUser(attrs);
          if (!res.error) return res;
          return callAuthRpc('createUser', attrs);
        },
        updateUserById: async (id: string, attrs: any) => {
          const res = await origAuth.admin.updateUserById(id, attrs);
          if (!res.error) return res;
          return callAuthRpc('updateUserById', { id, ...attrs });
        },
        deleteUser: async (id: string) => {
          const res = await origAuth.admin.deleteUser(id);
          if (!res.error) return res;
          return callAuthRpc('deleteUser', { id });
        },
      };
      return new Proxy(origAuth, {
        get(authTarget, authProp, authReceiver) {
          if (authProp === 'admin') {
            return rpcAdmin;
          }
          const v = Reflect.get(authTarget, authProp, authReceiver);
          return typeof v === 'function' ? v.bind(authTarget) : v;
        },
      });
    }
    const value = Reflect.get(activeClient, prop, receiver);
    if (typeof value === 'function') {
      return value.bind(activeClient);
    }
    return value;
  },
});

export function getPublicClient(): SupabaseClient<any, any, any> {
  return supabasePublicClient!;
}

export function getDemoClient(): SupabaseClient<any, any, any> {
  return supabaseDemoClient!;
}

export { supabaseDemoClient, supabasePublicClient };
