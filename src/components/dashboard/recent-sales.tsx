import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"

interface RecentSalesProps {
  data: {
    id: string
    name: string
    email: string
    amount: number
  }[]
}

export function RecentSales({ data }: RecentSalesProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Sales</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-8">
          {data.map((sale) => (
            <div key={sale.id} className="flex items-center">
              <Avatar className="h-9 w-9">
                <AvatarImage src={`https://avatar.vercel.sh/${sale.email}`} alt={sale.name} />
                <AvatarFallback>{sale.name.slice(0, 2).toUpperCase()}</AvatarFallback>
              </Avatar>
              <div className="ml-4 space-y-1">
                <p className="text-sm font-medium leading-none">{sale.name}</p>
                <p className="text-sm text-muted-foreground">{sale.email}</p>
              </div>
              <div className="ml-auto font-medium">${sale.amount}</div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
} 