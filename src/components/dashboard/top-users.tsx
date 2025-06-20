import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

interface TopUser {
  id: string
  name: string
  email: string
  phone: string
  requestCount: number
}

interface TopUsersProps {
  data: TopUser[]
}

export function TopUsers({ data }: TopUsersProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Top Users by Requests</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-8">
          {data.map((user) => (
            <div key={user.id} className="flex items-center">
              <Avatar className="h-9 w-9">
                <AvatarImage src={`https://avatar.vercel.sh/${user.email}`} alt={user.name} />
                <AvatarFallback>{user.name.slice(0, 2).toUpperCase()}</AvatarFallback>
              </Avatar>
              <div className="ml-4 space-y-1">
                <p className="text-sm font-medium leading-none">{user.name}</p>
                <p className="text-sm text-muted-foreground">{user.email}</p>
              </div>
              <div className="ml-auto font-medium">{user.requestCount} requests</div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
} 