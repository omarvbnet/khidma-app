import { UserLogs } from '@/components/user-logs';

export default function UserLogsPage() {
  return (
    <div className="container mx-auto py-10">
      <div className="space-y-4">
        <div>
          <h1 className="text-3xl font-bold">User Activity Logs</h1>
          <p className="text-gray-500 mt-2">
            Track all user status changes and who made them
          </p>
        </div>
        <UserLogs />
      </div>
    </div>
  );
} 